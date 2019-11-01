defmodule Spire.Leagues.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Leagues.League

  schema "matches" do
    field :date, :date
    field :link, :string
    field :title, :string

    belongs_to :league, League

    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:title, :date, :league_id, :link])
    |> validate_required([:title, :date, :league_id, :link])
    |> assoc_constraint(:league)
  end
end
