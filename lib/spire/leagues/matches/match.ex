defmodule Spire.Leagues.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Leagues.League
  alias Spire.Players.Player
  alias Spire.Players.PlayerMatch

  schema "matches" do
    field :date, :date
    field :link, :string
    field :title, :string

    belongs_to :league, League

    many_to_many :players, Player, join_through: PlayerMatch, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:title, :date, :league_id, :link])
    |> validate_required([:title, :league_id, :link])
    |> assoc_constraint(:league)
  end
end
