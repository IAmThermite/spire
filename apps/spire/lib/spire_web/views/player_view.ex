defmodule Spire.SpireWeb.PlayerView do
  use Spire.SpireWeb, :view

  def can_manage?(conn, id) do
    if Spire.SpireWeb.PermissionsHelper.is_logged_in?(conn) do
      cond do
        id == conn.assigns[:user].id ->
          true

        is_admin?(conn) ->
          true

        true ->
          false
      end
    else
      false
    end
  end

  def is_admin?(conn) do
    Spire.SpireWeb.PermissionsHelper.is_logged_in?(conn) and
      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin)
  end
end
