defmodule Spire.SpireDB.Repo.Migrations.CreateStatChanges do
  use Ecto.Migration

  def change do
    create table(:stats_all_change) do
      add :stat_name, :string, null: false
      add :change, :float, null: false
      add :upload_id, :integer, null: false
      add :stat_id, :integer, null: false
    end

    create table(:stats_individual_change) do
      add :stat_name, :string, null: false
      add :change, :float, null: false, default: 0
      add :upload_id, :integer, null: false
      add :stat_id, :integer, null: false
    end
  end
end
