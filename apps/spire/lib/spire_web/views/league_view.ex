defmodule SpireWeb.LeagueView do
  use SpireWeb, :view

  def can_manage?(conn) do
    if SpireWeb.PermissionsHelper.is_logged_in?(conn) do
      cond do
        SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
          true
        SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_leagues) ->
          true
        true ->
          false
      end
    else
      false
    end
  end
end
