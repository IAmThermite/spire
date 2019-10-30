defmodule Spire.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :steamid, :string, null: false
      add :steamid3, :string, null: false
      add :alias, :string, null: false
      add :avatar, :string, null: false
      add :league_id, references(:leagues, on_delete: :nilify_all)

      timestamps()
    end
    create unique_index(:players, [:steamid])
    create unique_index(:players, [:steamid3])

  end
end
