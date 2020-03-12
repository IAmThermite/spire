defmodule Spire.SpireDB.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :player_id, references(:players, on_delete: :delete_all)
      add :can_upload_logs, :boolean, default: true
      add :can_manage_logs, :boolean, default: false
      add :can_run_pipeline, :boolean, default: false
      add :can_manage_players, :boolean, default: false
      add :can_manage_matches, :boolean, default: false
      add :can_manage_leagues, :boolean, default: false
      add :is_super_admin, :boolean, default: false

      timestamps()
    end

    create unique_index(:permissions, [:player_id])
  end
end
