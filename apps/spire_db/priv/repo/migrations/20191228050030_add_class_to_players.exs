defmodule SpireDb.Repo.Migrations.AddClassToPlayers do
  use Ecto.Migration

  def change do
    alter table("players") do
      add :main_class, :string
    end
  end
end
