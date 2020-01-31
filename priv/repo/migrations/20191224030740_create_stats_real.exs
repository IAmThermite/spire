defmodule Spire.Repo.Migrations.CreateStatsReal do
  use Ecto.Migration

  def change do
    create table(:stats_all_real) do
      add :total_kills, :integer, default: 0
      add :total_deaths, :integer, default: 0
      add :total_assists, :integer, default: 0
      add :total_damage, :integer, default: 0
      add :total_healing, :integer, default: 0
      add :total_captures, :integer, default: 0

      add :longest_ks, :integer, default: 0

      add :average_dpm, :float, default: 0.0
      
      add :times_seen_scout, :integer, default: 0
      add :times_seen_soldier, :integer, default: 0
      add :times_seen_pyro, :integer, default: 0
      add :times_seen_demoman, :integer, default: 0
      add :times_seen_heavyweapons, :integer, default: 0
      add :times_seen_engineer, :integer, default: 0
      add :times_seen_medic, :integer, default: 0
      add :times_seen_sniper, :integer, default: 0
      add :times_seen_spy, :integer, default: 0

      add :number_of_logs, :integer, default: 0
      add :time_played, :integer, default: 0

      add :player_id, references(:players, on_delete: :delete_all)

      timestamps()
    end
    create unique_index(:stats_all_real, [:player_id])
    
    create table(:stats_individual_real) do
      add :class, :string, null: false

      add :kills, :integer, default: 0
      add :deaths, :integer, default: 0
      add :assists, :integer, default: 0
      add :dpm, :float, default: 0.0
      add :dmg_total, :integer, default: 0
      add :heal_total, :integer, default: 0

      add :shots_hit_pri, :integer, default: 0
      add :shots_fired_pri, :integer, default: 0
      add :accuracy_pri, :float, default: 0.0
      add :dmg_per_shot_pri, :float, default: 0.0

      add :shots_hit_sec, :integer, default: 0
      add :shots_fired_sec, :integer, default: 0
      add :accuracy_sec, :float, default: 0.0
      add :dmg_per_shot_sec, :float, default: 0.0

      add :airshots, :integer, default: 0
      add :headshots, :integer, default: 0
      add :backstabs, :integer, default: 0
      add :reflect_kills, :integer, default: 0
  
      add :ubers, :integer, default: 0
      add :kritz, :integer, default: 0
      add :drops, :integer, default: 0
      add :ave_time_to_build, :float, default: 0.0
      add :ave_uber_length, :float, default: 0.0
      add :ave_time_before_healing, :float, default: 0.0
      add :ave_time_before_using, :float, default: 0.0

      add :total_playtime, :integer, default: 0
      add :number_of_logs, :integer, default: 0

      add :player_id, references(:players, on_delete: :delete_all)

      timestamps()
    end
    create unique_index(:stats_individual_real, [:player_id, :class])
  end
end
