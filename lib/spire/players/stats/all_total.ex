defmodule Spire.Players.Stats.AllTotal do
  use Ecto.Schema

  alias Spire.Players.Player

  schema "stats_all_total" do
    field :total_kills, :integer, default: 0
    field :total_deaths, :integer, default: 0
    field :total_assists, :integer, default: 0
    field :total_damage, :integer, default: 0
    field :total_healing, :integer, default: 0
    field :total_captures, :integer, default: 0

    field :longest_ks, :integer, default: 0

    field :average_dpm, :float, default: 0.0
    
    field :times_seen_scout, :integer, default: 0
    field :times_seen_soldier, :integer, default: 0
    field :times_seen_pyro, :integer, default: 0
    field :times_seen_demoman, :integer, default: 0
    field :times_seen_heavyweapons, :integer, default: 0
    field :times_seen_engineer, :integer, default: 0
    field :times_seen_medic, :integer, default: 0
    field :times_seen_sniper, :integer, default: 0
    field :times_seen_spy, :integer, default: 0

    field :number_of_logs, :integer, default: 0
    field :time_played, :integer, default: 0

    belongs_to :player, Player

    timestamps()
  end
end
