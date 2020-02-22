defmodule Spire.SpireWeb.LeagueView do
  use Spire.SpireWeb, :view

  def can_manage?(conn) do
    if Spire.SpireWeb.PermissionsHelper.is_logged_in?(conn) do
      cond do
        Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
          true
        Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_leagues) ->
          true
        true ->
          false
      end
    else
      false
    end
  end
end
