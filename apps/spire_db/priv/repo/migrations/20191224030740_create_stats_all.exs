defmodule Spire.SpireDB.Repo.Migrations.CreateStatsReal do
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

      add :player_id, references(:players, on_delete: :delete_all), null: false

      timestamps()
    end
    create unique_index(:stats_all_real, [:player_id])

    create table(:stats_all_total) do
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

      add :player_id, references(:players, on_delete: :delete_all), null: false

      timestamps()
    end
    create unique_index(:stats_all_total, [:player_id])
  end
end
