defmodule Spire.Players do
  @moduledoc """
  The Players context.
  """

  import Ecto.Query, warn: false
  alias Spire.Repo

  alias Spire.Players.Player
  alias SpireWeb.SteamHelper

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
    |> Repo.preload([
      :league,
      :stats_individual_real,
      :stats_individual_total,
      :stats_all_real,
      :stats_all_total
    ])
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
    case Repo.get_by(Player, steamid64: user.steamid) do
      nil ->
        opts = %{
          steamid64: user.steamid,
          steamid3: SteamHelper.community_id_to_steam_id3(String.to_integer(user.steamid)),
          steamid: SteamHelper.community_id_to_steam_id(String.to_integer(user.steamid)),
          avatar: user.avatarfull,
          alias: user.personaname
        }
        create_player(opts)

      player ->
        {:ok, player}
    end
  end

  def get_by_steamid3(steamid3) do
    Repo.get_by(Player, steamid3: steamid3)
  end

  def get_by_steamid(steamid) do
    Repo.get_by(Player, steamid: steamid)
  end
end
