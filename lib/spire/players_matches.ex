defmodule Spire.PlayersMatches do
  @moduledoc """
  The PlayersMatches context.
  """

  import Ecto.Query, warn: false
  alias Spire.Repo

  alias Spire.PlayersMatches.PlayerMatch

  @doc """
  Returns the list of players_matches.

  ## Examples

      iex> list_players_matches()
      [%PlayerMatch{}, ...]

  """
  def list_players_matches(player_id) do
    Repo.all(from(p in PlayerMatch, where: p.player_id == ^player_id))
    |> Repo.preload(:match) # only preload match
  end

  @doc """
  Returns the list of players_matches.

  ## Examples

      iex> list_players_matches()
      [%PlayerMatch{}, ...]

  """
  def list_matches_players(match_id) do
    Repo.all(from(m in PlayerMatch, where: m.match_id == ^match_id))
    |> Repo.preload(:player) # only preload player

  end

  @doc """
  Gets a single player_match.

  Raises `Ecto.NoResultsError` if the Player match does not exist.

  ## Examples

      iex> get_player_match!(123)
      %PlayerMatch{}

      iex> get_player_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player_match!(id), do: Repo.get!(PlayerMatch, id)

  @doc """
  Creates a player_match.

  ## Examples

      iex> create_player_match(%{field: value})
      {:ok, %PlayerMatch{}}

      iex> create_player_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player_match(attrs \\ %{}) do
    %PlayerMatch{}
    |> PlayerMatch.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player_match.

  ## Examples

      iex> update_player_match(player_match, %{field: new_value})
      {:ok, %PlayerMatch{}}

      iex> update_player_match(player_match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player_match(%PlayerMatch{} = player_match, attrs) do
    player_match
    |> PlayerMatch.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PlayerMatch.

  ## Examples

      iex> delete_player_match(player_match)
      {:ok, %PlayerMatch{}}

      iex> delete_player_match(player_match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player_match(%PlayerMatch{} = player_match) do
    Repo.delete(player_match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player_match changes.

  ## Examples

      iex> change_player_match(player_match)
      %Ecto.Changeset{source: %PlayerMatch{}}

  """
  def change_player_match(%PlayerMatch{} = player_match) do
    PlayerMatch.changeset(player_match, %{})
  end
end
