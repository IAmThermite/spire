defmodule SpireWeb.AdminController do
  use SpireWeb, :controller
  alias Spire.Players
  alias Spire.Players.Permissions

  def index(conn, _params) do
    # get uploads in queue
    # get leagues
    render(conn, "index.html")
  end
end
