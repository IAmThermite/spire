defmodule Spire.Players.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logs" do
    field :logfile, :string
    field :map, :string

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:logfile, :map])
    |> validate_required([:logfile])
  end
end
