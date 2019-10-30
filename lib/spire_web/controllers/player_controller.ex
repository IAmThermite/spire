defmodule SpireWeb.PlayerController do
  use SpireWeb, :controller

  alias Spire.Players
  alias Spire.Leagues
  alias Spire.Players.Player

  def index(conn, _params) do
    players = Players.list_players()
    render(conn, "index.html", players: players)
  end

  def new(conn, _params) do
    changeset = Players.change_player(%Player{})
    league_options = Enum.map(Leagues.list_leagues(), fn(l) -> [value: l.id, key: l.name] end)
    render(conn, "new.html", league_options: league_options, changeset: changeset)
  end

  def create(conn, %{"player" => player_params}) do
    case Players.create_player(player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player created successfully.")
        |> redirect(to: Routes.player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    render(conn, "show.html", player: player)
  end

  def edit(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    league_options = Enum.map(Leagues.list_leagues(), fn(l) -> [value: l.id, key: l.name] end)
    changeset = Players.change_player(player)
    render(conn, "edit.html", player: player, league_options: league_options, changeset: changeset)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = Players.get_player!(id)

    case Players.update_player(player, player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player updated successfully.")
        |> redirect(to: Routes.player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", player: player, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    {:ok, _player} = Players.delete_player(player)

    conn
    |> put_flash(:info, "Player deleted successfully.")
    |> redirect(to: Routes.player_path(conn, :index))
  end
end
