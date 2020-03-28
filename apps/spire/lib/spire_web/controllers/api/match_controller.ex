defmodule Spire.SpireWeb.Api.MatchController do
  use Spire.SpireWeb, :controller

  alias Spire.SpireDB.Leagues.Matches
  alias Spire.SpireDB.Leagues.League
  alias Spire.SpireDB.Players.Player
  alias Spire.SpireDB.Logs.Log
  alias Spire.SpireDB.Repo
  alias Spire.Utils

  def show(conn, %{"id" => id}) do
    match =
      Matches.get_match!(id)
      |> Repo.preload([:league, :logs, :players])
      |> Utils.struct_to_json_map()
      |> clean_players()
      |> clean_logs()
      |> clean_league()

    json(conn, match)
  end

  defp clean_players(%{players: [%Player{} | _tail]} = match) do
    players = Enum.map(match.players, fn player ->
      player
      |> Utils.struct_to_json_map([:league, :stats_all, :stats_individual, :permissions, :logs, :matches])
    end)

    Map.put(match, :players, players)
  end

  defp clean_players(match) do
    Map.delete(match, :players)
  end

  defp clean_logs(%{logs: [%Log{} | _tail]} = match) do
    logs = Enum.map(match.logs, fn log ->
      Utils.struct_to_json_map(log, [:match])
    end)

    Map.put(match, :logs, logs)
  end

  defp clean_logs(match) do
    Map.delete(match, :logs)
  end

  defp clean_league(%{league: %League{}} = match) do
    league = Utils.struct_to_json_map(match.league, [:matches, :players])

    Map.put(match, :league, league)
  end

  defp clean_league(match), do: match
end
