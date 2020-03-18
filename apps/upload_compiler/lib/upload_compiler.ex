defmodule Spire.UploadCompiler do
  require Logger
  use Broadway

  alias Spire.SpireDB.Repo
  alias Spire.SpireDB.Players
  alias Spire.SpireDB.Players.Stats
  alias Spire.Utils.SteamUtils
  alias Broadway.Message
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

    real = Map.has_key?(data, "match")

    upload = Jason.decode!(data["upload"])

    %HTTPoison.Response{body: body, status_code: 200} =
      HTTPoison.get!("https://logs.tf/json/#{upload["logfile"]}")

    log_json = Jason.decode!(body)

    players =
      log_json
      |> get_player_stubs()
      |> Enum.map(fn stub ->
        Players.get_or_create_from_stub(stub)
      end)

    stats_all =
      Enum.map(players, fn player ->
        Stats.get_or_create_stats_all_for_player!(player, real)
      end)

    stats_individual =
      Enum.map(players, fn player ->
        # TODO: fix for older logs
        player_log_json = get_log_json_for_player(player, log_json)

        Enum.map(player_log_json["class_stats"], fn stat ->
          Stats.get_or_create_stats_individual_for_player!(player, stat["type"], real)
        end)
      end)
      |> List.flatten()

    updated_stats_all =
      Enum.map(stats_all, fn stat ->
        player_log_json = get_log_json_for_player(stat.player, log_json)

        AllCalculations.calculate_stats(stat, player_log_json)
      end)

    updated_stats_individual =
      Enum.map(stats_individual, fn stat ->
        player_log_json = get_log_json_for_player(stat.player, log_json)

        IndividualCalculations.calculate_stats(stat, player_log_json)
      end)

    persist_stats([updated_stats_all | updated_stats_individual], upload)

    message
    |> Message.update_data(fn _data -> log_json end)
  end

  def get_player_stubs(log_json) do
    log_players = log_json["names"]

    Map.keys(log_players)
    |> Enum.map(fn key ->
      steamid64 = SteamUtils.steamid_to_steamid64(key)
      steamid3 = SteamUtils.community_id_to_steam_id3(steamid64)
      steamid = SteamUtils.community_id_to_steam_id(steamid64)

      {:ok, %{"personaname" => alias, "avatarfull" => avatar}} =
        SteamUtils.get_steam_player(steamid64)

      %{
        alias: alias,
        avatar: avatar,
        steamid64: steamid64,
        steamid3: steamid3,
        steamid: steamid
      }
    end)
  end

  def persist_stats(stats, upload) do
    multis =
      Enum.reduce(stats, Ecto.Multi.new(), fn stat, multi ->
        Ecto.Multi.update(
          multi,
          %{player_id: stat.player_id},
          stat
        )
      end)

    multis_with_upload = [Ecto.Multi.update(multis, %{upload: upload.id}, upload) | multis]
    Repo.transaction(multis_with_upload)
  end

  defp get_log_json_for_player(player, log_json) do
    log_json["players"][player.steamid3] || log_json["players"][player.steamid]
  end
end
