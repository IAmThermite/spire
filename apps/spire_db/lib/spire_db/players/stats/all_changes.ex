defmodule Spire.SpireDB.Players.Stats.AllChanges do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stats_all_changes" do
    field :stat_name, :string
    field :change, :float

    belongs_to :stat, Spire.SpireDB.Players.Stats.All
    belongs_to :upload, Spire.SpireDB.Logs.Uploads.Upload
  end

  def changeset(changes, attrs) do
    changes
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:stat_name, :change, :upload_id, :stat_id])
    |> unique_constraint(:stat_name, name: :stats_all_changes_stat_name_upload_id_stat_id_index)
  end
end
