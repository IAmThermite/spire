defmodule Spire.Repo.Migrations.AddFieldsToLogs do
  use Ecto.Migration

  def change do
    alter table("logs") do
      add :t1_score, :integer, null: false
      add :t2_score, :integer, null: false
      add :date, :naive_datetime, null: false
    end
  end
end
