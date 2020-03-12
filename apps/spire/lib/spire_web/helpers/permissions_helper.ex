defmodule Spire.SpireWeb.PermissionsHelper do
  alias Spire.SpireDB.Players.Permissions

  def is_logged_in?(conn) do
    conn.assigns[:user] != nil
  end

  def has_permissions_for?(conn, resource) do
    if is_logged_in?(conn) do
      permissions = Permissions.get_permissions_for_player(conn.assigns[:user].id)

      case permissions do
        %{is_super_admin: true} ->
          true

        %{^resource => true} ->
          true

        _ ->
          false
      end
    else
      false
    end
  end
end
