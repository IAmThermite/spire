defmodule SpireWeb.LeagueController do
  use SpireWeb, :controller

  alias Spire.Leagues
  alias Spire.Leagues.League

  def index(conn, _params) do
    leagues = Leagues.list_leagues()
    render(conn, "index.html", leagues: leagues)
  end

  def new(conn, _params) do
    changeset = Leagues.change_league(%League{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"league" => league_params}) do
    case Leagues.create_league(league_params) do
      {:ok, league} ->
        conn
        |> put_flash(:info, "League created successfully.")
        |> redirect(to: Routes.league_path(conn, :show, league))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    league = Leagues.get_league!(id)
    render(conn, "show.html", league: league)
  end

  def edit(conn, %{"id" => id}) do
    league = Leagues.get_league!(id)
    changeset = Leagues.change_league(league)
    render(conn, "edit.html", league: league, changeset: changeset)
  end

  def update(conn, %{"id" => id, "league" => league_params}) do
    league = Leagues.get_league!(id)

    case Leagues.update_league(league, league_params) do
      {:ok, league} ->
        conn
        |> put_flash(:info, "League updated successfully.")
        |> redirect(to: Routes.league_path(conn, :show, league))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", league: league, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    league = Leagues.get_league!(id)
    {:ok, _league} = Leagues.delete_league(league)

    conn
    |> put_flash(:info, "League deleted successfully.")
    |> redirect(to: Routes.league_path(conn, :index))
  end
end
