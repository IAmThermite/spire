defmodule Spire.SpireDB.Repo.Migrations.AddWeaponDamageToStats do
  use Ecto.Migration

  def change do
    alter table("stats_individual") do
      add :dmg_pri, :integer, default: 0
      add :dmg_sec, :integer, default: 0
    end
  end
end
