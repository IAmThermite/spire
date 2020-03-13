defmodule Spire.SpireDB.Players.Stats do
  @moduledoc """
  The Leagues context.
  """

  import Ecto.Query, warn: false
  alias Spire.SpireDB.Repo

  alias Spire.SpireDB.Players.Stats.AllReal
  alias Spire.SpireDB.Players.Stats.AllTotal
  alias Spire.SpireDB.Players.Stats.IndividualReal
  alias Spire.SpireDB.Players.Stats.IndividualTotal

  def get_or_create_stats_all_for_player!(player, true) do
    case Repo.get_by(AllReal, player_id: player.id) do
      nil ->
        Repo.insert!(%AllReal{player_id: player.id})

      stats ->
        stats
    end
    |> Repo.preload([:player])
  end

  def get_or_create_stats_all_for_player!(player, false) do
    case Repo.get_by(AllTotal, player_id: player.id) do
      nil ->
        Repo.insert!(%AllTotal{player_id: player.id})

      stats ->
        stats
    end
    |> Repo.preload([:player])
  end

  def get_or_create_stats_individual_for_player!(player, class, true) do
    case Repo.get_by(IndividualReal, player_id: player.id, class: class) do
      nil ->
        Repo.insert!(%IndividualReal{player_id: player.id, class: class})

      stats ->
        stats
    end
    |> Repo.preload([:player])
  end

  def get_or_create_stats_individual_for_player!(player, class, false) do
    case Repo.get_by(IndividualTotal, player_id: player.id, class: class) do
      nil ->
        Repo.insert!(%IndividualTotal{player_id: player.id, class: class})

      stats ->
        stats
    end
    |> Repo.preload([:player])
  end
end
