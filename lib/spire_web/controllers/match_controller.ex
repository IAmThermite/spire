defmodule SpireWeb.MatchController do
  use SpireWeb, :controller

  alias Spire.Leagues
  alias Spire.Leagues.Matches
  alias Spire.Leagues.Matches.Match

  def index(conn, %{"league_id" => league_id}) do
    matches = Matches.list_matches()
    league = Leagues.get_league!(league_id)
    render(conn, "index.html", matches: matches, league: league)
  end

  def new(conn, %{"league_id" => league_id}) do
    changeset = Matches.change_match(%Match{})
    league = Leagues.get_league!(league_id)
    render(conn, "new.html", changeset: changeset, league: league)
  end

  def create(conn, %{"league_id" => league_id, "match" => match_params}) do
    params = Map.put(match_params, "league_id", league_id)
    case Matches.create_match(params) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: Routes.match_path(conn, :show, match))

      {:error, %Ecto.Changeset{} = changeset} ->
        league = Leagues.get_league!(league_id)
        render(conn, "new.html", changeset: changeset, league: league)
    end
  end

  def show(conn, %{"id" => id}) do
    match = Matches.get_match!(id)
    render(conn, "show.html", match: match, league: match.league)
  end

  def edit(conn, %{"id" => id}) do
    match = Matches.get_match!(id)
    changeset = Matches.change_match(match)
    render(conn, "edit.html", match: match, changeset: changeset, league: match.league)
  end

  def update(conn, %{"id" => id, "match" => match_params}) do
    match = Matches.get_match!(id)

    case Matches.update_match(match, match_params) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match updated successfully.")
        |> redirect(to: Routes.match_path(conn, :show, match))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", match: match, changeset: changeset, league: match.league)
    end
  end

  def delete(conn, %{"id" => id}) do
    match = Matches.get_match!(id)
    {:ok, _match} = Matches.delete_match(match)

    conn
    |> put_flash(:info, "Match deleted successfully.")
    |> redirect(to: Routes.league_match_path(conn, :index, match.league_id))
  end
end
