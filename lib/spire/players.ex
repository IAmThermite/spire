defmodule Spire.Players do
  @moduledoc """
  The Players context.
  """

  import Ecto.Query, warn: false
  alias Spire.Repo

  alias Spire.Players.Player

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
    |> Repo.preload(:league)
  end

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players_by_match(123)
      [%Player{}, ...]

  """
  def list_players_by_match(match_id) do
    Repo.all(from(p in "players_matches", select: {}, where: p.match_id == ^match_id))
    |> Repo.preload([:player])
  end

   @doc """
  Returns the list of players.

  ## Examples

      iex> list_players_by_log(123)
      [%Player{}, ...]

  """
  def list_players_by_log(log_id) do
    Repo.all(from(p in "players_logs", where: p.log_id == ^log_id))
    |> Repo.preload([:player])
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id) do
    Repo.get!(Player, id)
    |> Repo.preload([:league])
  end

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{source: %Player{}}

  """
  def change_player(%Player{} = player) do
    Player.changeset(player, %{})
  end

  def get_or_create_from_auth(%Ueberauth.Auth{} = auth) do
    user = auth.extra.raw_info.user
    case Repo.get_by(Player, steamid: user.steamid) do
      nil ->
        opts = %{
          steamid: user.steamid,
          steamid3: user.steamid, # TODO: actually do steamid3 stuff
          avatar: user.avatarfull,
          alias: user.personaname
        }
        create_player(opts)

      player ->
        {:ok, player}
    end
  end
end
