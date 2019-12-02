defmodule Spire.Repo.Migrations.AddDivisionToPlayers do
  use Ecto.Migration

  def change do
    alter table("players") do
      add :division, :string
    end
  end
end
