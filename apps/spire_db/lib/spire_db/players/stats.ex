defmodule Spire.SpireDB.Players.Stats do
  @moduledoc """
  The Leagues context.
  """

  import Ecto.Query, warn: false
  alias Spire.SpireDB.Repo
  alias Spire.SpireDB.Players.Player
  alias Spire.SpireDB.Players.Stats.All
  alias Spire.SpireDB.Players.Stats.Individual
  alias Spire.Utils

  def get_or_create_stats_all_for_player!(player, type) do
    case get_stats_all(player, type) do
      nil ->
        Repo.insert!(%All{player_id: player.id, type: type})

      stats ->
        stats
    end
    |> Repo.preload([:player])
  end

  def get_or_create_stats_individual_for_player!(player, class, type) do
    case get_stats_individual(player, type, class) do
      nil ->
        Repo.insert!(%Individual{player_id: player.id, class: class, type: type})

      stats ->
        stats
    end
    |> Repo.preload([:player])
  end

  def get_stats_all(%Player{} = player, type) do
    Repo.get_by(All, player_id: player.id, type: type)
  end

  def get_stats_all(_player, _type), do: nil

  def get_stats_individual(%Player{} = player, type, class) do
    Repo.get_by(Individual, player_id: player.id, class: class, type: type)
  end

  def get_stats_individual(_player, _type, _class), do: nil

  def get_deltas(player_1_stats, player_2_stats, fields) do
    cond do
      player_1_stats == nil ->
        Utils.struct_to_json_map(player_1_stats, [
          :__meta__,
          :id,
          :type,
          :class,
          :player,
          :player_id,
          :inserted_at,
          :updated_at
        ])

      player_2_stats == nil ->
        Utils.struct_to_json_map(player_2_stats, [
          :__meta__,
          :id,
          :type,
          :class,
          :player,
          :player_id,
          :inserted_at,
          :updated_at
        ])

      true ->
        Enum.reduce(fields, %{}, fn field, acc ->
          Map.put(acc, field, Map.get(player_1_stats, field) - Map.get(player_2_stats, field))
        end)
    end
  end

  def get_stats_individual_fields() do
    Individual.__schema__(:fields)
    |> List.delete(:id)
    |> List.delete(:type)
    |> List.delete(:class)
    |> List.delete(:player)
    |> List.delete(:player_id)
    |> List.delete(:inserted_at)
    |> List.delete(:updated_at)
  end

  def get_stats_all_fields() do
    All.__schema__(:fields)
    |> List.delete(:id)
    |> List.delete(:type)
    |> List.delete(:player)
    |> List.delete(:player_id)
    |> List.delete(:inserted_at)
    |> List.delete(:updated_at)
  end
end
