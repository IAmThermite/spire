defmodule Spire.SpireDB.Repo.Migrations.AddMoreFieldsToMatches do
  use Ecto.Migration

  def change do
    alter table("matches") do
      add :team_1_damage, :integer, default: 0
      add :team_2_damage, :integer, default: 0
      add :team_1_kills, :integer, default: 0
      add :team_2_kills, :integer, default: 0
    end
  end
end
