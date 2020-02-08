defmodule SpireWeb.LayoutView do
  use SpireWeb, :view

  def is_admin?(conn) do
    with %{id: id} <- conn.assigns[:user],
         %{id: id} <- Spire.Players.Permissions.get_permissions_for_player(id)
    do
      true
    else
      _err ->
        false
    end
  end
end
