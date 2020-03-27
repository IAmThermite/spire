defmodule Spire.SpireDB.Leagues.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Leagues.League
  alias Spire.SpireDB.Players.Player
  alias Spire.SpireDB.Players.PlayersMatches
  alias Spire.SpireDB.Logs.Log

  schema "matches" do
    field :title, :string
    field :date, :date
    field :link, :string

    belongs_to :league, League

    has_many :logs, Log

    many_to_many :players, Player, join_through: PlayersMatches, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:title, :date, :league_id, :link])
    |> validate_required([:title, :league_id, :link])
    |> assoc_constraint(:league)
    |> unique_constraint(:title)
    |> unique_constraint(:link)
  end
end
