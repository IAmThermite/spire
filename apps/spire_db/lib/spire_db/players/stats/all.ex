defmodule Spire.SpireDB.Players.Stats.All do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Players.Player

  schema "stats_all" do
    field :type, :string, default: "OTHER"

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

  def changeset(stats, attrs \\ %{}) do
    stats
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:player_id, :type])
    |> unique_constraint(:player_id, name: :stats_all_player_id_type_index)
  end
end
