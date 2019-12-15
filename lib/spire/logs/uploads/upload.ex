defmodule Spire.Logs.Uploads.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Logs.Log
  alias Spire.Players.Player

  schema "log_upload" do
    field :approved, :boolean
    field :processed, :boolean

    belongs_to :log, Log
    belongs_to :player, Player, foreign_key: :uploaded_by

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:approved, :processed, :log_id, :uploaded_by])
    |> validate_required([:approved, :processed, :log_id, :uploaded_by])
    |> unique_constraint([:log_id, :uploaded_by], name: :uploader_log_index)
    |> assoc_constraint(:log, :player)
  end
end
