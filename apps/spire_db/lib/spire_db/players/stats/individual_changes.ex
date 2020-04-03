defmodule Spire.SpireDB.Players.Stats.IndividualChanges do
  use Ecto.Schema

  schema "individual_changes" do
    field :stat_name, :string
    field :change, :float
    field :upload_id, :integer
    field :stat_id, :integer
  end
end
