defmodule Spire.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Leagues.Matches.Match

  schema "logs" do
    field :logfile, :string
    field :map, :string
    field :t1_score, :integer
    field :t2_score, :integer
    field :date, :date

    belongs_to :match, Match

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:logfile, :map, :t1_score, :t2_score, :date, :match_id])
    |> validate_required([:logfile, :t1_score, :t2_score, :date])
    |> unique_constraint(:logfile)
    |> assoc_constraint(:match)
  end
end
