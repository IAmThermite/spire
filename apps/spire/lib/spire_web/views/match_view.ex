defmodule Spire.SpireWeb.MatchView do
  use Spire.SpireWeb, :view

  def can_manage?(conn) do
    if Spire.SpireWeb.PermissionsHelper.is_logged_in?(conn) do
      cond do
        Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
          true

        Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_matches) ->
          true

        true ->
          false
      end
    else
      false
    end
  end

  def calculate_match_score(match) do
    Enum.reduce(match.logs, {0, 0}, fn log, {blue, red} ->
      {blue + log.blue_score, red + log.red_score}
    end)
  end
end
