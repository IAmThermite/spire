defmodule Spire.SpireDB.Repo.Migrations.AddScoreToMatches do
  use Ecto.Migration

  def change do
    alter table("matches") do
      add :team_1_score, :integer, default: 0
      add :team_2_score, :integer, default: 0
    end
  end
end
