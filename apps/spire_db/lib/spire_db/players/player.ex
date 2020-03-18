defmodule Spire.SpireDB.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Leagues.League
  alias Spire.SpireDB.Leagues.Matches.Match
  alias Spire.SpireDB.Players.Permissions.Permission
  alias Spire.SpireDB.Players.Stats.Individual
  alias Spire.SpireDB.Players.Stats.All

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

    many_to_many :matches, Match, join_through: "players_matches", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [
      :steamid64,
      :steamid3,
      :steamid,
      :avatar,
      :alias,
      :division,
      :main_class,
      :league_id
    ])
    |> validate_required([:steamid64, :steamid3, :steamid, :alias, :avatar])
    |> unique_constraint(:steamid64)
    |> unique_constraint(:steamid3)
    |> unique_constraint(:steamid)
    |> assoc_constraint(:league)
  end
end
