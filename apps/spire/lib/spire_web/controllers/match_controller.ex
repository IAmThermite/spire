defmodule Spire.SpireWeb.MatchController do
  use Spire.SpireWeb, :controller

  alias Spire.SpireDB.Leagues
  alias Spire.SpireDB.Leagues.Matches
  alias Spire.SpireDB.Leagues.Matches.Match
  alias Spire.SpireDB.Logs.Log

  plug Spire.SpireWeb.Plugs.RequireAuthentication when action not in [:index, :show]
  plug :require_permissions when action not in [:index, :show]

  def index(conn, %{"league_id" => league_id}) do
    league = Leagues.get_league!(league_id)
    matches = Matches.list_matches_by_league(league.id)
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
    players = match.players

    maps =
      case match.logs do
        [%Log{} | _tail] ->
          Enum.map(match.logs, fn log ->
            log.map
          end)

        _ ->
          nil
      end

    render(conn, "show.html",
      match: match,
      league: match.league,
      players: players,
      maps: maps
    )
  end

  def edit(conn, %{"id" => id}) do
    match = Matches.get_match!(id)
    changeset = Matches.change_match(match)
    render(conn, "edit.html", match: match, league: match.league, changeset: changeset)
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

  defp require_permissions(conn, _) do
    cond do
      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
        conn

      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_matches) ->
        conn

      true ->
        conn
        |> put_flash(:error, "You do not have the permissions to do this")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt
    end
  end
end
