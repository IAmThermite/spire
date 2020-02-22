defmodule Spire.SpireDB.Logs.Uploads.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Logs.Log
  alias Spire.SpireDB.Players.Player

  schema "log_upload" do
    field :approved, :boolean, default: false
    field :processed, :boolean, default: false

    belongs_to :log, Log
    belongs_to :player, Player, foreign_key: :uploaded_by

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:approved, :processed, :log_id, :uploaded_by])
    |> validate_required([:approved, :processed, :log_id, :uploaded_by])
    |> unique_constraint(:log_id)
    |> assoc_constraint(:log)
    |> assoc_constraint(:player)
  end
end
