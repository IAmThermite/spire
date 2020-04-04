defmodule Spire.UploadCompiler do
  require Logger
  use Broadway

  alias Broadway.Message

  alias Spire.SpireDB.Repo
  alias Spire.SpireDB.Players
  alias Spire.SpireDB.Players.Stats
  alias Spire.SpireDB.Logs.Uploads
  alias Spire.SpireDB.Logs
  alias Spire.SpireDB.Leagues.Matches
  alias Spire.Utils.SteamUtils
  alias Spire.UploadCompiler.IndividualCalculations
  alias Spire.UploadCompiler.AllCalculations
  alias Spire.UploadCompiler.DeltaCalculations

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwaySQS.Producer, queue_url: Application.get_env(:upload_compiler, :sqs_queue_url)}
      ],
      processors: [
        default: []
      ]
    )
  end

  @impl true
  def handle_message(_, %Message{data: data} = message, _) do
    try do
      Logger.info("Recieved Message", message: message)

      %{"log" => message_log, "upload" => message_upload} = json = Jason.decode!(data)

      real = json["match"] != %{}

      match =
        if real do
          Matches.get_match!(json["match"]["id"])
        else
          nil
        end

      log =
        Logs.get_log!(message_log["id"])

      struct = %Uploads.Upload{
        uploaded_by: message_upload["uploaded_by"],
        id: message_upload["id"],
        log_id: message_upload["log_id"]
      }

      {:ok, upload} = Uploads.update_upload(struct, %{status: "IN_QUEUE"})

      %HTTPoison.Response{body: body, status_code: 200} =
        HTTPoison.get!("https://logs.tf/json/#{log.logfile}")

      log_json = Jason.decode!(body)

      players =
        log_json
        |> get_player_stubs()
        |> Enum.map(fn stub ->
          Players.get_or_create_from_stub(stub)
          |> Repo.preload([:matches, :logs, :league])
        end)

      stats_all = get_stats_all(players, real)

      stats_individual = get_stats_individual(players, log_json, real)

      updated_stats_all =
        Enum.map(stats_all, fn stat ->
          player_log_json = get_log_json_for_player(stat.player, log_json)

          attrs =
            AllCalculations.calculate_stats(stat, player_log_json)
            |> Map.from_struct()

            %Ecto.Changeset{valid?: true} = Stats.All.changeset(stat, attrs)
        end)

      updated_stats_individual =
        Enum.map(stats_individual, fn stat ->
          player_log_json = get_log_json_for_player(stat.player, log_json)

          attrs =
            IndividualCalculations.calculate_stats(stat, player_log_json)
            |> Map.from_struct()

            %Ecto.Changeset{valid?: true} = Stats.Individual.changeset(stat, attrs)
        end)

      deltas_all =
        Enum.map(stats_all, fn current_stats ->
          updated_stats = get_updated_stats_all(current_stats, updated_stats_all)
          DeltaCalculations.calculate_deltas(current_stats, updated_stats, upload)
        end)

      deltas_individual =
        Enum.map(stats_individual, fn current_stats ->
          updated_stats = get_updated_stats_individual(current_stats, updated_stats_individual)
          DeltaCalculations.calculate_deltas(current_stats, updated_stats, upload)
        end)

      # link players to log
      players_to_log =
        Enum.map(players, fn player ->
          %Ecto.Changeset{valid?: true} = Players.Player.changeset_add_log(player, log)
        end)

      # link players to matches
      players_to_match =
        Enum.map(players, fn player ->
          %Ecto.Changeset{valid?: true} = Players.Player.changeset_add_match(player, match)
        end)

      stats_changesets =
        Enum.concat([updated_stats_all, updated_stats_individual, players_to_log, players_to_match])

      insert_changesets = Enum.concat([deltas_all, deltas_individual]) |> List.flatten()

      {:ok, _multis} = persist_stats(stats_changesets, insert_changesets, upload, match, log)

      Message.update_data(message, fn _data -> message end)
    rescue
      exception ->
        Logger.error("Error occured processing log", exception: exception)
        Airbrake.report(exception)
        Message.update_data(message, fn _data -> message end)
    end
  end

  def get_player_stubs(log_json) do
    log_players = log_json["names"]

    Map.keys(log_players)
    |> Enum.map(fn key ->
      %{steamid64: steamid64, steamid3: steamid3, steamid: steamid} = SteamUtils.get_steamids(key)

      {:ok, %{"personaname" => alias, "avatarfull" => avatar}} =
        SteamUtils.get_steam_player(steamid64)

      %{
        "alias" => alias,
        "avatar" => avatar,
        "steamid64" => steamid64,
        "steamid3" => steamid3,
        "steamid" => steamid
      }
    end)
  end

  def update_match_score(%Matches.Match{} = match, log) do
    team_1_score = match.team_1_score + log.blue_score
    team_2_score = match.team_1_score + log.red_score
    Matches.Match.changeset(match, %{team_1_score: team_1_score, team_2_score: team_2_score})
  end

  def update_match_score(_, _), do: nil

  def persist_stats(stat_changesets, insert_changesets, upload, match, log) do
    stat_multis =
      Enum.reduce(stat_changesets, Ecto.Multi.new(), fn stat, multi ->
        Ecto.Multi.update(
          multi,
          # gross unique name hack
          length(multi.operations),
          stat
        )
      end)

    insert_multis = Enum.reduce(insert_changesets, stat_multis, fn change, multi ->
      Ecto.Multi.insert(multi, length(multi.operations), change)
    end)

    all_multis =
      case update_match_score(match, log) do
        %Ecto.Changeset{} = changeset ->
          Ecto.Multi.update(insert_multis, "set_match_score", changeset)

        _ ->
          insert_multis
      end

    case Repo.transaction(all_multis) do
      {:ok, _} ->
        Logger.info("Successfuly calculated and updated stats")
        {:ok, _upload} = Uploads.update_upload(upload, %{status: "PROCESSED"})
        {:ok, all_multis}

      {:error, error} ->
        Logger.error("Failed to update stats", error: error)
        {:ok, _upload} = Uploads.update_upload(upload, %{status: "FAILED"})
        {:error, error}
    end
  end

  defp get_log_json_for_player(player, log_json) do
    log_json["players"][player.steamid3] || log_json["players"][player.steamid]
  end

  defp get_stats_all(players, real) do
    Enum.map(players, fn player ->
      if real do
        [
          Stats.get_or_create_stats_all_for_player!(player, "MATCH"),
          Stats.get_or_create_stats_all_for_player!(player, "COMBINED")
        ]
      else
        [
          Stats.get_or_create_stats_all_for_player!(player, "OTHER"),
          Stats.get_or_create_stats_all_for_player!(player, "COMBINED")
        ]
      end
    end)
    |> List.flatten()
  end

  defp get_stats_individual(players, log_json, real) do
    Enum.map(players, fn player ->
      player_log_json = get_log_json_for_player(player, log_json)

      Enum.map(player_log_json["class_stats"], fn stat ->
        if stat["type"] != "undefined" do
          if real do
            [
              Stats.get_or_create_stats_individual_for_player!(player, stat["type"], "MATCH"),
              Stats.get_or_create_stats_individual_for_player!(player, stat["type"], "COMBINED")
            ]
          else
            [
              Stats.get_or_create_stats_individual_for_player!(player, stat["type"], "OTHER"),
              Stats.get_or_create_stats_individual_for_player!(player, stat["type"], "COMBINED")
            ]
          end
        else
          nil
        end
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn stat ->
      stat != nil
    end)
  end

  defp get_updated_stats_all(stat, stats) do
    Enum.find(stats, fn each_stat ->
      each_stat.data.player_id == stat.player_id && each_stat.data.type == stat.type
    end)
  end

  defp get_updated_stats_individual(stat, stats) do
    Enum.find(stats, fn each_stat ->
      each_stat.data.player_id == stat.player_id && each_stat.data.type == stat.type && each_stat.data.class == stat.class
    end)
  end
end
