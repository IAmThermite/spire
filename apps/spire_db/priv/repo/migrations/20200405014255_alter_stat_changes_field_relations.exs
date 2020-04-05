defmodule Spire.SpireDB.Repo.Migrations.AlterStatChangesFieldRelations do
  use Ecto.Migration

  def change do
    alter table("stats_all_changes") do
      modify :stat_id, references(:stats_all, on_delete: :delete_all)
      modify :upload_id, references(:uploads, on_delete: :delete_all)
    end

    alter table("stats_individual_changes") do
      modify :stat_id, references(:stats_individual, on_delete: :delete_all)
      modify :upload_id, references(:uploads, on_delete: :delete_all)
    end
  end
end
