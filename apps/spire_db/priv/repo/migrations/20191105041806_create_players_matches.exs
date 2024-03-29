defmodule Spire.SpireDB.Repo.Migrations.CreatePlayersMatches do
  use Ecto.Migration

  def change do
    create table(:players_matches) do
      add :player_id, references(:players, on_delete: :restrict), null: false
      add :match_id, references(:matches, on_delete: :delete_all), null: false

      timestamps()
    end

    create(index(:players_matches, [:player_id]))
    create(index(:players_matches, [:match_id]))

    create unique_index(:players_matches, [:player_id, :match_id])
  end
end
