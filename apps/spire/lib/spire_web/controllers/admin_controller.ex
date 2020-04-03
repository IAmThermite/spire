defmodule Spire.SpireWeb.AdminController do
  use Spire.SpireWeb, :controller
  alias Spire.SpireDB.Logs.Uploads

  plug Spire.SpireWeb.Plugs.RequireAuthentication
  plug :require_permissions

  def index(conn, _params) do
    uploads = Uploads.list_uploads()
    render(conn, "index.html", uploads: uploads)
  end

  defp require_permissions(conn, _) do
    if Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) or
         Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_logs) do
      conn
    else
      conn
      |> put_flash(:error, "You do not have the permissions to do this")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end
end
