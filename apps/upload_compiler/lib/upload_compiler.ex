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
    Logger.info("Recieved Message", message: message)

    %{"log" => message_log, "upload" => message_upload} = json = Jason.decode!(data)

    real = json["match"] != %{}

    match = if real do
      Matches.get_match!(json["match"]["id"])
    else
      nil
    end

    log = Logs.get_log!(message_log["id"])

    struct = %Uploads.Upload{uploaded_by: message_upload["uploaded_by"], id: message_upload["id"], log_id: message_upload["log_id"]}
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

        Stats.All.changeset(stat, attrs)
      end)

    updated_stats_individual =
      Enum.map(stats_individual, fn stat ->
        player_log_json = get_log_json_for_player(stat.player, log_json)

        attrs =
          IndividualCalculations.calculate_stats(stat, player_log_json)
          |> Map.from_struct()

        Stats.Individual.changeset(stat, attrs)
      end)

    # link players to log
    players_to_log = Enum.map(players, fn player ->
      Players.Player.changeset_add_log(player, log)
    end)

    # link players to matches
    players_to_match = Enum.map(players, fn player ->
      Players.Player.changeset_add_match(player, match)
    end)

    changesets = Enum.concat([updated_stats_all, updated_stats_individual, players_to_log, players_to_match])
    {:ok, _multis} = persist_stats(changesets, upload)

    message
    |> Message.update_data(fn _data -> log_json end)
  end

  def get_player_stubs(log_json) do
    log_players = log_json["names"]

    Map.keys(log_players)
    |> Enum.map(fn key ->
      %{steamid64: steamid64, steamid3: steamid3, steamid: steamid} =
        SteamUtils.get_steamids(key)

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

  def persist_stats(stats, upload) do
    multis =
      Enum.reduce(stats, Ecto.Multi.new(), fn stat, multi ->
        Ecto.Multi.update(
          multi,
          length(multi.operations), # gross unique name hack
          stat
        )
      end)

    case Repo.transaction(multis) do
      {:ok, _} ->
        Logger.info("Successfuly calculated and updated stats")
        Uploads.update_upload(upload, %{status: "PROCESSED"})
        {:ok, multis}
      {:error, error} ->
        Logger.error("Failed to update stats", error: error)
        Uploads.update_upload(upload, %{status: "FAILED"})
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
          Stats.get_or_create_stats_all_for_player!(player,  real),
          Stats.get_or_create_stats_all_for_player!(player, false)
        ]
      else
        Stats.get_or_create_stats_all_for_player!(player,  real)
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
              Stats.get_or_create_stats_individual_for_player!(player, stat["type"], real),
              Stats.get_or_create_stats_individual_for_player!(player, stat["type"], false)
            ]
          else
            Stats.get_or_create_stats_individual_for_player!(player, stat["type"], false)
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
end
