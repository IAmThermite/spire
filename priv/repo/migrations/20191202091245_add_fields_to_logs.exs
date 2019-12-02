defmodule Spire.Repo.Migrations.AddFieldsToLogs do
  use Ecto.Migration

  def change do
    alter table("logs") do
      add :t1_score, :integer, null: false
      add :t2_score, :integer, null: false
      add :date, :date, null: false
      add :match_id, references(:matches, on_delete: :restrict)
    end
  end
end
