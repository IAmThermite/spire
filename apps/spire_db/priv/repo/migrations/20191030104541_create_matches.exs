defmodule SpireDb.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :title, :string, null: false
      add :date, :date
      add :link, :string, null: false
      add :league_id, references(:leagues, on_delete: :restrict)

      timestamps()
    end

  end
end
