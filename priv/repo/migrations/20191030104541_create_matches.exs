defmodule Spire.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :title, :string
      add :date, :date
      add :link, :string
      add :league_id, references(:leagues, on_delete: :restrict)
      
      timestamps()
    end

  end
end
