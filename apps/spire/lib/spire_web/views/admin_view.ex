defmodule SpireWeb.AdminView do
  use SpireWeb, :view

  def has_permissions_for?(conn, resource) do
    if SpireWeb.PermissionsHelper.is_logged_in?(conn) do
      cond do
        SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
          true
        SpireWeb.PermissionsHelper.has_permissions_for?(conn, resource) ->
          true
        true ->
          false
      end
    else
      false
    end
  end
end
