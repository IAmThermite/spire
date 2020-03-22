defmodule Spire.SpireWeb.Api.PlayerController do
  use Spire.SpireWeb, :controller

  alias Spire.SpireDB.Players
  alias Spire.SpireDB.Leagues.League

  def index(conn, %{"search" => search}) do
    players =
      Players.list_players("%#{search}%")
      |> clean_players()
    json(conn, players)
  end

  def index(conn, _params) do
    players =
      Players.list_players()
      |> clean_players()
    json(conn, players)
  end

  def show(conn, %{"id" => id}) do
    player =
      Players.get_by_steamid64(id)
      |> clean_player()
    json(conn, player)
  end

  defp clean_players(players) do
    Enum.map(players, fn player ->
      clean_player(player)
    end)
  end

  def clean_player(player) do
    league =
      case player.league do
        %League{} = league ->
          league
          |> Map.from_struct()
          |> Map.drop([:__meta__, :matches, :players])
        _ ->
          nil
      end
    player
    |> Map.from_struct()
    |> Map.put(:league, league)
    |> Map.drop([:__meta__, :logs, :matches, :uploads, :permissions, :stats_all, :stats_individual])
  end
end
