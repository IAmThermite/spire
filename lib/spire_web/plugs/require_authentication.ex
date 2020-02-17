defmodule SpireWeb.Plugs.RequireAuthentication do
  import Plug.Conn

  alias Spire.Repo
  alias Spire.Players.Player

  def init(_params) do
  end

  def call(conn, _params) do
    player_id = get_session(conn, :user_id)

    cond do
      player = player_id && Repo.get(Player, player_id) ->
        conn
      true ->
        conn
          |> Phoenix.Controller.redirect(to: SpireWeb.Router.Helpers.auth_path(conn, :request, :steam))
          |> halt()
    end
  end
end
