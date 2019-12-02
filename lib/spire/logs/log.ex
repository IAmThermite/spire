defmodule Spire.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logs" do
    field :logfile, :string
    field :map, :string
    field :t1_score, :integer
    field :t2_score, :integer
    field :date, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:logfile, :map])
    |> validate_required([:logfile])
  end
end
