defmodule SpireWeb.LogHelper do
  require Logger

  alias Spire.Players
  alias Spire.Leagues.Matches

  def extract_players_from_log(log_json) do
    {:ok, []}
  end

  def can_upload?(log, conn) do
    # check if they have permissions
    # is_player_part_of_log(log, conn.assigns[:user])
    true
  end

  def handle_upload(log, conn, players) do
    # check if log has a match and if user can execute pipline or not
    match = Matches.get_match!(log.match_id)
    SpireWeb.FunctionHelper.invoke("spire_stats_compiler", %{"log" => log, "players" => players, "match" => match})
  end

  def is_player_part_of_log(log, player) do
    false
  end

  defp get_player(steamid) do
    case SpireWeb.SteamHelper.get_steamid_type(steamid) do
      :steamid ->
        Players.get_by_steamid(steamid)

      :steamid3 ->
        Players.get_by_steamid3(steamid)
        
      _ ->
        # should not get here
        Logger.error("SpireWeb.LogHelper.get_player/1", steamid: steamid)
        nil
    end
  end
end