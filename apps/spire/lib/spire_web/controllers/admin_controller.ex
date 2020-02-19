defmodule SpireWeb.AdminController do
  use SpireWeb, :controller
  alias SpireDb.Players
  alias SpireDb.Players.Permissions

  plug SpireWeb.Plugs.RequireAuthentication
  plug :require_permissions

  def index(conn, _params) do
    # get uploads in queue
    # get leagues
    render(conn, "index.html")
  end

  defp require_permissions(conn, _) do
    if SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) do
      conn
    else
      conn
      |> put_flash(:error, "You do not have the permissions to do this")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end
end
