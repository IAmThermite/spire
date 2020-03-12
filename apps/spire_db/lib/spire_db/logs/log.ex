defmodule Spire.SpireDB.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Leagues.Matches.Match

  schema "logs" do
    field :logfile, :string
    field :map, :string
    field :red_score, :integer
    field :blue_score, :integer
    field :red_kills, :integer
    field :blue_kills, :integer
    field :red_damage, :integer
    field :blue_damage, :integer
    field :length, :integer
    field :date, :date

    belongs_to :match, Match

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :logfile,
      :map,
      :red_score,
      :blue_score,
      :red_kills,
      :blue_kills,
      :red_damage,
      :blue_damage,
      :length,
      :date,
      :match_id
    ])
    |> validate_required([
      :logfile,
      :map,
      :red_score,
      :blue_score,
      :red_kills,
      :blue_kills,
      :red_damage,
      :blue_damage,
      :length,
      :date
    ])
    |> unique_constraint(:logfile)
    |> assoc_constraint(:match)
  end
end
