defmodule Spire.SpireDB.Players.Stats.Individual do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.SpireDB.Players.Player

  @soldier_demo_fields [:airshots]
  @pyro_fields [:reflect_kills]
  @medic_fields [:heal_total, :ubers, :krits, :ave_time_to_build, :ave_uber_length, :ave_time_before_healing, :ave_time_before_using]
  @sniper_fields [:headshots]
  @spy_fields [:backstabs]

  schema "stats_individual" do
    field :type, :string, null: false, default: "OTHER"
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
    |> validate_required([:player_id, :class, :type])
    |> unique_constraint(:player_id, name: :stats_individual_player_id_class_type_index)
  end

  def generic_fields() do
    __schema__(:fields)
    |> Enum.filter(fn field -> field not in @soldier_demo_fields end)
    |> Enum.filter(fn field -> field not in @pyro_fields end)
    |> Enum.filter(fn field -> field not in @medic_fields end)
    |> Enum.filter(fn field -> field not in @sniper_fields end)
    |> Enum.filter(fn field -> field not in @spy_fields end)
    |> Enum.filter(fn field -> field not in [:__meta__, :id, :inserted_at, :player_id, :player, :updated_at, :type, :class] end)
  end

  def soldier_demo_fields() do
    @soldier_demo_fields ++ generic_fields()
  end

  def pyro_fields() do
    @pyro_fields ++ generic_fields()
  end

  def medic_fields() do
    @medic_fields ++ generic_fields()
    |> Enum.filter(fn field ->
      field not in [:kills_sec, :shots_hit_sec, :shots_fired_sec, :accuracy_sec, :dmg_per_shot_sec, :dmg_sec]
    end)
  end

  def sniper_fields() do
    @sniper_fields ++ generic_fields()
  end

  def spy_fields() do
    @spy_fields ++ generic_fields()
  end

  def fields_for_class(class) do
    case class do
      "soldier" ->
        soldier_demo_fields()
      "pyro" ->
        pyro_fields()
      "demoman" ->
        soldier_demo_fields()
      "medic" ->
        medic_fields()
      "sniper" ->
        sniper_fields()
      "spy" ->
        spy_fields()
      _ ->
        generic_fields()
    end
  end
end
