defmodule Spire.SpireDB.Repo.Migrations.CreateLeagues do
  use Ecto.Migration

  def change do
    create table(:leagues) do
      add :name, :string, null: false
      add :website, :string, null: false
      add :main, :boolean, default: false, null: false

      timestamps()
    end

  end
end
