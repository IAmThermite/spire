defmodule Spire.SpireDB.Repo.Migrations.AlterStatTypes do
  use Ecto.Migration

  def change do
    drop  index("stats_all", [:player_id, :real])
    alter table("stats_all") do
      add :type, :string, null: false, default: "OTHER"
      remove :real
    end
    create unique_index(:stats_all, [:player_id, :type])

    drop  index("stats_individual", [:player_id, :class, :real])
    alter table("stats_individual") do
      add :type, :string, null: false, default: "OTHER"
      remove :real
    end
    create unique_index(:stats_individual, [:player_id, :class, :type])
  end
end
