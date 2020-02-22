defmodule Spire.SpireDB.Leagues.League do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Players.Player
  alias Spire.SpireDB.Leagues.Matches.Match

  schema "leagues" do
    field :main, :boolean, default: false
    field :name, :string
    field :website, :string

    timestamps()

    has_many :players, Player
    has_many :matches, Match
  end

  @doc false
  def changeset(league, attrs) do
    league
    |> cast(attrs, [:name, :website, :main])
    |> validate_required([:name, :website, :main])
    |> unique_constraint(:name)
  end
end
