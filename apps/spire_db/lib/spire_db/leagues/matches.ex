defmodule Spire.SpireDB.Leagues.Matches do
  @moduledoc """
  The Leagues.Matches context.
  """

  import Ecto.Query, warn: false
  alias Spire.SpireDB.Repo

  alias Spire.SpireDB.Leagues.Matches.Match
  alias Spire.SpireDB.Players.PlayersMatches

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches() do
    Repo.all(from m in Match)
    |> sort_matches_by_date()
  end

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches_by_league(123)
      [%Match{}, ...]

  """
  def list_matches_by_league(league_id) do
    Repo.all(from(m in Match, where: m.league_id == ^league_id))
    |> Repo.preload([:logs])
    |> sort_matches_by_date()
  end

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches_by_player(123)
      [%Match{}, ...]

  """
  def list_matches_by_player(player_id) do
    Repo.all(from(m in PlayersMatches, where: m.player_id == ^player_id))
    |> Repo.preload([:match])
    |> Enum.map(fn m ->
      m.match
    end)
    |> sort_matches_by_date()
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id) do
    Repo.get!(Match, id)
    |> Repo.preload([:league, :logs, :players])
  end

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{source: %Match{}}

  """
  def change_match(%Match{} = match) do
    Match.changeset(match, %{})
  end

  defp sort_matches_by_date(matches) do
    Enum.sort_by(matches, fn match -> {match.date.year, match.date.month, match.date.day} end)
    |> Enum.reverse()
  end
end
