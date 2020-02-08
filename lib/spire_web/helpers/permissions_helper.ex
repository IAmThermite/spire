defmodule SpireWeb.PermissionsHelper do
  alias Spire.Players.Permissions
  def logged_in?(conn) do
    conn.assigns[:user] != nil
  end

  def has_permssions_for?(conn, resource) do
    if logged_in?(conn) do
      permissions = Permissions.get_permissions_for_player(conn.assigns[:user].id)
      case permissions do
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
