defmodule Spire.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Leagues.League
  alias Spire.Leagues.Matches.Match

  schema "players" do
    field :alias, :string
    field :steamid, :string
    field :avatar, :string
    field :steamid3, :string
    field :division, :string

    belongs_to :league, League

    many_to_many :matches, Match, join_through: "players_matches", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:steamid, :steamid3, :avatar, :alias, :division, :league_id])
    |> validate_required([:steamid, :steamid3, :alias])
    |> unique_constraint(:steamid)
    |> unique_constraint(:steamid3)
    |> assoc_constraint(:league)
  end
end
