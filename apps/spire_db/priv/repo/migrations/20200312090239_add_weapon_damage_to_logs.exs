defmodule Spire.SpireDB.Repo.Migrations.AddWeaponDamageToLogs do
  use Ecto.Migration

  def change do
    alter table("stats_individual_real") do
      add :dmg_pri, :integer, default: 0
      add :dmg_sec, :integer, default: 0
    end

    alter table("stats_individual_total") do
      add :dmg_pri, :integer, default: 0
      add :dmg_sec, :integer, default: 0
    end
  end
end
