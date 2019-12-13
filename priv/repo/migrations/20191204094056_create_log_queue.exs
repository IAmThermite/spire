defmodule Spire.Repo.Migrations.CreateLogQueue do
  use Ecto.Migration

  def change do
    create table(:log_queue) do
      add :approved, :boolean, default: false
      add :log_id, references(:logs, on_delete: :delete_all)
      add :match_id, references(:matches, on_delete: :delete_all)
      add :uploaded_by, references(:players, on_delete: :delete_all)

      timestamps()
    end
    create(index(:log_queue, [:log_id]))
    create(index(:log_queue, [:match_id]))
    create(index(:log_queue, [:uploaded_by]))

    create unique_index(:log_queue, [:uploaded_by, :log_id, :match_id])
  end
end
