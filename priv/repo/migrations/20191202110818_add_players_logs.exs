defmodule Spire.Repo.Migrations.AddPlayersLogs do
  use Ecto.Migration

  def change do
    create table(:players_logs) do
      add :player_id, references(:players, on_delete: :restrict)
      add :log_id, references(:logs, on_delete: :delete_all)
      timestamps()
    end
    create(index(:players_logs, [:player_id]))
    create(index(:players_logs, [:log_id]))

    create unique_index(:players_logs, [:player_id, :log_id])
  end
end
