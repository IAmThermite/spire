defmodule Spire.SpireDB.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :logfile, :string, null: false
      add :map, :string

      timestamps()
    end

    create unique_index(:logs, [:logfile])

  end
end
