defmodule Spire.Repo.Migrations.CreateLogsMatches do
  use Ecto.Migration

  def change do
    create table(:logs_matches) do
      add :log_id, references(:logs, on_delete: :delete_all)
      add :match_id, references(:matches, on_delete: :delete_all)
      timestamps()
    end
    create(index(:logs_matches, [:log_id]))
    create(index(:logs_matches, [:match_id]))

    create unique_index(:logs_matches, [:log_id, :match_id])
  end
end
