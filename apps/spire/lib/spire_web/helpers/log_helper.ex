defmodule Spire.SpireWeb.LogHelper do
  require Logger

  alias Spire.SpireDB.Leagues.Matches
  alias Spire.SpireDB.Players.Permissions
  alias Spire.Utils

  def can_upload?(log_json, conn) do
    permissions = Permissions.get_permissions_for_player(conn.assigns[:user].id)

    case permissions do
      %{can_upload_logs: val} ->
        val

      %{can_manage_logs: true} ->
        true

      %{is_super_admin: true} ->
        true

      _ ->
        is_player_part_of_log?(log_json["players"], conn.assigns[:user])
    end
  end

  def handle_upload(upload, log) do
    Logger.debug("#{__MODULE__}.handle_upload", log: log, upload: upload)

    match =
      case get_match_from_log(log.match_id) do
        %Matches.Match{} = m ->
          Utils.struct_to_json_map(m, [:league, :league_id, :logs, :players])

        _ ->
          %{}
      end

    Spire.Utils.SQSUtils.send_message(
      Jason.encode!(%{
        upload: Utils.struct_to_json_map(upload, [:player, :log]),
        log: Utils.struct_to_json_map(log, [:match]),
        match: match
      })
    )
  end

  def is_player_part_of_log?(log_players, %{steamid: steamid, steamid3: steamid3} = _player) do
    case log_players do
      %{^steamid => _name} ->
        true

      %{^steamid3 => _name} ->
        true

      _ ->
        false
    end
  end

  defp get_match_from_log(match_id) when is_integer(match_id) do
    Matches.get_match!(match_id)
  end

  defp get_match_from_log(_match_id) do
    nil
  end
end
