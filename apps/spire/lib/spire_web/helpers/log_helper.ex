defmodule SpireWeb.LogHelper do
  require Logger

  alias SpireDb.Players
  alias SpireDb.Leagues.Matches

  alias SpireDb.Players.Permissions

  def extract_players_from_log(log_json) do
    {:ok, []}
  end

  def can_upload?(log, conn) do
    permissions = Permissions.get_permissions_for_player(conn.assigns[:user].id)
    # check if they have permissions
    # is_player_part_of_log(log, conn.assigns[:user])
    true
  end

  def handle_upload(conn, log, upload) do
    match = get_match_from_log(log[:match_id])
    SpireWeb.FunctionHelper.invoke("spire_stats_compiler", %{"log" => log, "match" => match, "upload" => upload})
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
        Logger.error("#{__MODULE__}.get_player/1", steamid: steamid)
        nil
    end
  end

  defp get_match_from_log(match_id) when is_integer(match_id) do
    Matches.get_match!(match_id)
  end

  defp get_match_from_log(_match_id) do
    nil
  end
end
