defmodule SpireWeb.LayoutView do
  use SpireWeb, :view

  alias SpireDb.Players.Permissions
  alias SpireWeb.PermissionsHelper, as: Helper

  def is_admin?(conn) do
    if Helper.is_logged_in?(conn) do
      permissions = Permissions.get_permissions_for_player(conn.assigns[:user].id)
      cond do
        permissions.is_super_admin ->
          true
        permissions.can_manage_logs ->
          true
        permissions.can_run_pipeline ->
          true
        permissions.can_manage_matches ->
          true
        permissions.can_manage_leagues ->
          true
        true ->
          false
      end
    else
      false
    end
  end
end