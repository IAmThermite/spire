defmodule Spire.SpireDB.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Leagues.League
  alias Spire.SpireDB.Leagues.Matches.Match
  alias Spire.SpireDB.Players.Permissions.Permission
  alias Spire.SpireDB.Players.Stats.Individual
  alias Spire.SpireDB.Players.Stats.All
  alias Spire.SpireDB.Players.PlayersMatches
  alias Spire.SpireDB.Players.PlayersLogs
  alias Spire.SpireDB.Logs.Log

  schema "players" do
    field :alias, :string
    field :steamid64, :string
    field :steamid3, :string
    field :steamid, :string
    field :avatar, :string
    field :division, :string
    field :main_class, :string

    belongs_to :league, League
    has_one :permissions, Permission

    has_many :stats_individual, Individual
    has_many :stats_all, All

    many_to_many :matches, Match, join_through: PlayersMatches
    many_to_many :logs, Log, join_through: PlayersLogs, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:steamid64, :steamid3, :steamid, :alias, :avatar])
    |> unique_constraint(:steamid64)
    |> unique_constraint(:steamid3)
    |> unique_constraint(:steamid)
    |> assoc_constraint(:league)
  end

  def changeset_add_match(player, match) when not is_nil(match) do
    player
    |> cast(%{}, __schema__(:fields))
    |> put_assoc(:matches, [match | player.matches])
  end

  def changeset_add_match(player, _match) do
    player
    |> cast(%{}, __schema__(:fields))
  end

  def changeset_add_log(player, log) when not is_nil(log) do
    player
    |> cast(%{}, __schema__(:fields))
    |> put_assoc(:logs, [log | player.logs])
  end

  def changeset_add_log(player, _log) do
    player
    |> cast(%{}, __schema__(:fields))
  end
end
