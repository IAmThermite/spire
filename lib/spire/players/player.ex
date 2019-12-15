defmodule Spire.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Leagues.League
  alias Spire.Leagues.Matches.Match
  alias Spire.Players.Permissions

  schema "players" do
    field :alias, :string
    field :steamid64, :string
    field :steamid3, :string
    field :steamid, :string
    field :avatar, :string
    field :division, :string

    belongs_to :league, League
    has_one :permissions, Permissions

    many_to_many :matches, Match, join_through: "players_matches", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:steamid64, :steamid3, :steamid, :avatar, :alias, :division, :league_id])
    |> validate_required([:steamid64, :steamid3, :steamid, :alias, :avatar])
    |> unique_constraint(:steamid64)
    |> unique_constraint(:steamid3)
    |> unique_constraint(:steamid)
    |> assoc_constraint(:league)
  end
end
