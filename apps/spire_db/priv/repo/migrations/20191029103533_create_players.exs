defmodule SpireDb.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :steamid64, :string, null: false
      add :steamid3, :string, null: false
      add :steamid, :string, null: false
      add :alias, :string, null: false
      add :avatar, :string, null: false
      add :league_id, references(:leagues, on_delete: :nilify_all)

      timestamps()
    end
    create unique_index(:players, [:steamid64])
    create unique_index(:players, [:steamid3])
    create unique_index(:players, [:steamid])
    create index(:players, [:alias])

  end
end
