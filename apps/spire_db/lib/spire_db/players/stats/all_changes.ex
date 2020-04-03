defmodule Spire.SpireDB.Players.Stats.AllChanges do
  use Ecto.Schema

  schema "all_changes" do
    field :stat_name, :string
    field :change, :float
    field :upload_id, :integer
    field :stat_id, :integer
  end
end
