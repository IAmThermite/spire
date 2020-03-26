defmodule Spire.SpireDB.Players.Stats do
  @moduledoc """
  The Leagues context.
  """

  import Ecto.Query, warn: false
  alias Spire.SpireDB.Repo

  alias Spire.SpireDB.Players.Stats.All
  alias Spire.SpireDB.Players.Stats.Individual

  def get_or_create_stats_all_for_player!(player, real) do
    case Repo.get_by(All, player_id: player.id, real: real) do
      nil ->
        Repo.insert!(%All{player_id: player.id, real: real})

      stats ->
        stats
    end
    |> Repo.preload([:player])
  end

  def get_or_create_stats_individual_for_player!(player, class, real) do
    case Repo.get_by(Individual, player_id: player.id, class: class, real: real) do
      nil ->
        Repo.insert!(%Individual{player_id: player.id, class: class, real: real})

      stats ->
        stats
    end
    |> Repo.preload([:player])
  end
end
