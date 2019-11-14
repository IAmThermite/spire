defmodule Spire.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Leagues.League
  alias Spire.Leagues.Matches.Match
  alias Spire.PlayersMatches.PlayerMatch

  schema "players" do
    field :alias, :string
    field :steamid, :string
    field :avatar, :string
    field :steamid3, :string

    belongs_to :league, League

    many_to_many :matches, Match, join_through: PlayerMatch, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:steamid, :steamid3, :avatar, :alias, :league_id])
    |> validate_required([:steamid, :avatar, :steamid3, :alias])
    |> unique_constraint(:steamid)
    |> unique_constraint(:steamid3)
    |> assoc_constraint(:league)
  end
end
