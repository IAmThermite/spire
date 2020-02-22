defmodule Spire.SpireDB.Repo.Migrations.AddFieldsToLogs do
  use Ecto.Migration

  def change do
    alter table("logs") do
      add :red_score, :integer, null: false
      add :blue_score, :integer, null: false
      add :red_kills, :integer, null: false
      add :blue_kills, :integer, null: false
      add :red_damage, :integer, null: false
      add :blue_damage, :integer, null: false
      add :length, :integer, null: false
      add :date, :date, null: false
      add :match_id, references(:matches, on_delete: :restrict)
    end
  end
end
