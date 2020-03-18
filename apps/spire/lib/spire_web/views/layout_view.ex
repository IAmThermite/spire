defmodule Spire.SpireWeb.LayoutView do
  use Spire.SpireWeb, :view

  alias Spire.SpireDB.Players.Permissions
  alias Spire.SpireWeb.PermissionsHelper, as: Helper

  def is_admin?(conn) do
    if Helper.is_logged_in?(conn) do
      permissions = Permissions.get_permissions_for_player(conn.assigns[:user].id)

      cond do
        permissions == nil ->
          false

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
