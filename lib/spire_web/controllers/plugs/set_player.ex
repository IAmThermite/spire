defmodule SpireWeb.Plugs.SetPlayer do
  import Plug.Conn

  alias Spire.Repo
  alias Spire.Players.Player

  def init(_params) do
  end

  def call(conn, _params) do
    player_id = get_session(conn, :player_id)

    cond do
      player = player_id && Repo.get(Player, player_id) ->
        conn
        |> assign(:player, player)
      true ->
        conn
        |> assign(:player, nil)
    end
  end
end