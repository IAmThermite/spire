defmodule Spire.SpireDB.Repo.Migrations.CreateStatChanges do
  use Ecto.Migration

  def change do
    create table(:stats_all_changes) do
      add :stat_name, :string, null: false
      add :change, :float, null: false
      add :upload_id, :integer, null: false
      add :stat_id, :integer, null: false
    end
    create unique_index(:stats_all_changes, [:stat_name, :change, :upload_id, :stat_id])

    create table(:stats_individual_changes) do
      add :stat_name, :string, null: false
      add :change, :float, null: false, default: 0
      add :upload_id, :integer, null: false
      add :stat_id, :integer, null: false
    end
    create unique_index(:stats_individual_changes, [:stat_name, :change, :upload_id, :stat_id])
  end
end
