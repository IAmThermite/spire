defmodule Spire.SpireDB.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Leagues.League
  alias Spire.SpireDB.Leagues.Matches.Match
  alias Spire.SpireDB.Players.Permissions.Permission
  alias Spire.SpireDB.Players.Stats.IndividualReal
  alias Spire.SpireDB.Players.Stats.IndividualTotal
  alias Spire.SpireDB.Players.Stats.AllReal
  alias Spire.SpireDB.Players.Stats.AllTotal

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

    has_many :stats_individual_real, IndividualReal
    has_many :stats_individual_total, IndividualTotal
    has_one :stats_all_real, AllReal
    has_one :stats_all_total, AllTotal

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
