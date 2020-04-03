defmodule Spire.SpireDB.Leagues.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Leagues.League
  alias Spire.SpireDB.Players.Player
  alias Spire.SpireDB.Players.PlayersMatches
  alias Spire.SpireDB.Logs.Log

  @required_fields [:title, :league_id, :link, :team_1_score, :team_2_score]

  schema "matches" do
    field :title, :string
    field :date, :date
    field :link, :string
    field :team_1_score, :integer, default: 0
    field :team_2_score, :integer, default: 0

    belongs_to :league, League

    has_many :logs, Log, on_delete: :nilify_all

    many_to_many :players, Player, join_through: PlayersMatches, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, __schema__(:fields))
    |> validate_required(@required_fields)
    |> assoc_constraint(:league)
    |> unique_constraint(:title)
    |> unique_constraint(:link)
  end
end
