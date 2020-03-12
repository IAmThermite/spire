defmodule Spire.SpireWeb.AdminView do
  use Spire.SpireWeb, :view

  def has_permissions_for?(conn, resource) do
    if Spire.SpireWeb.PermissionsHelper.is_logged_in?(conn) do
      cond do
        Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
          true

        Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, resource) ->
          true

        true ->
          false
      end
    else
      false
    end
  end
end
