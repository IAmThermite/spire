defmodule Spire.UploadCompiler.DeltaCalculations do
  alias Spire.SpireDB.Players.Stats.AllChanges
  alias Spire.SpireDB.Players.Stats.IndividualChanges

  def calculate_deltas(current_stats, %{changes: updated_stats} = _updated_stats_changeset, upload) do
    keys =
      Map.from_struct(current_stats)
      |> Map.drop([:__meta__, :id, :player_id, :player, :type, :class, :inserted_at, :updated_at])
      |> Map.keys()

    Enum.map(keys, fn key ->
      delta = Map.get(updated_stats, key, 0) - Map.get(current_stats, key)
      # when there is a change and the stats arent new
      if delta != 0 && Map.get(updated_stats, key, 0) != 0 && Map.get(current_stats, key) != 0  do
        attrs = %{
          stat_name: Atom.to_string(key),
          change: delta,
          upload_id: upload.id,
          stat_id: current_stats.id
        }
        if Map.get(current_stats, :class) do
          %Ecto.Changeset{valid?: true} = IndividualChanges.changeset(%IndividualChanges{}, attrs)
        else
          %Ecto.Changeset{valid?: true} = AllChanges.changeset(%AllChanges{}, attrs)
        end
      else
        nil
      end
    end)
    |> Enum.filter(fn delta ->
      delta != nil
    end)
  end
end
