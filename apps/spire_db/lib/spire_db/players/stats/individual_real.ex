defmodule Spire.SpireDB.Players.Stats.IndividualReal do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Players.Player

  schema "stats_individual_real" do
    field :class, :string

    field :kills, :integer, default: 0
    field :deaths, :integer, default: 0
    field :assists, :integer, default: 0
    field :dpm, :float, default: 0.0
    field :dmg_total, :integer, default: 0
    field :heal_total, :integer, default: 0

    # primary weapon stats
    field :kills_pri, :integer, default: 0
    field :shots_hit_pri, :integer, default: 0
    field :shots_fired_pri, :integer, default: 0
    field :accuracy_pri, :float, default: 0.0
    field :dmg_per_shot_pri, :float, default: 0.0
    field :dmg_pri, :integer, default: 0

    # secondary weapon stats
    field :kills_sec, :integer, default: 0
    field :shots_hit_sec, :integer, default: 0
    field :shots_fired_sec, :integer, default: 0
    field :accuracy_sec, :float, default: 0.0
    field :dmg_per_shot_sec, :float, default: 0.0
    field :dmg_sec, :integer, default: 0

    # misc stats
    field :airshots, :integer, default: 0
    field :headshots, :integer, default: 0
    field :backstabs, :integer, default: 0
    field :reflect_kills, :integer, default: 0

    # medic stats
    field :ubers, :integer, default: 0
    field :kritz, :integer, default: 0
    field :drops, :integer, default: 0
    field :ave_time_to_build, :float, default: 0.0
    field :ave_uber_length, :float, default: 0.0
    field :ave_time_before_healing, :float, default: 0.0
    field :ave_time_before_using, :float, default: 0.0

    field :total_playtime, :integer, default: 0
    field :number_of_logs, :integer, default: 0

    belongs_to :player, Player

    timestamps()
  end

  def changeset(stats, attrs \\ %{}) do
    stats
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:player_id, :class])
  end
end
