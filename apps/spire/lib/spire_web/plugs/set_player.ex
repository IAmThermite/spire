defmodule SpireWeb.Plugs.SetPlayer do
  import Plug.Conn

  alias SpireDb.Repo
  alias SpireDb.Players.Player

  def init(_params) do
  end

  def call(conn, _params) do
    player_id = get_session(conn, :user_id)

    cond do
      player = player_id && Repo.get(Player, player_id) ->
        conn
        |> assign(:user, player)
      true ->
        conn
        |> assign(:user, nil)
    end
  end
end
