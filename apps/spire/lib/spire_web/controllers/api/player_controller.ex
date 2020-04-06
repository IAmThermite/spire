defmodule Spire.SpireWeb.Api.PlayerController do
  use Spire.SpireWeb, :controller

  alias Spire.SpireDB.Players
  alias Spire.SpireDB.Players.Stats
  alias Spire.SpireDB.Leagues.League
  alias Spire.Utils

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

  def compare(
        conn,
        %{"player_1_id" => player_1_id, "player_2_id" => player_2_id, "type" => type} = params
      ) do
    player_1 = Players.get_by_steamid64(String.trim(player_1_id))
    player_2 = Players.get_by_steamid64(String.trim(player_2_id))

    modified_type =
      String.trim(type)
      |> String.upcase()

    stats =
      case params do
        %{"class" => class} ->
          modified_class =
            String.trim(class)
            |> String.downcase()

          player_1_stats = Stats.get_stats_individual(player_1.id, modified_type, modified_class)
          player_2_stats = Stats.get_stats_individual(player_2.id, modified_type, modified_class)
          fields = Stats.Individual.fields_for_class(class)
          deltas = Stats.get_deltas(player_1_stats, player_2_stats, fields)

          %{
            player_1_stats: clean_stat(player_1_stats) |> Map.take(fields),
            player_2_stats: clean_stat(player_2_stats) |> Map.take(fields),
            deltas: Map.take(deltas, fields)
          }

        _ ->
          player_1_stats = Stats.get_stats_all(player_1.id, modified_type)
          player_2_stats = Stats.get_stats_all(player_2.id, modified_type)
          fields = Stats.get_stats_all_fields()
          deltas = Stats.get_deltas(player_1_stats, player_2_stats, fields)

          %{
            player_1_stats: clean_stat(player_1_stats),
            player_2_stats: clean_stat(player_2_stats),
            deltas: deltas
          }
      end

    json(
      conn,
      Map.merge(stats, %{
        player_1_id => clean_player(player_1) |> Map.drop([:stats_all, :stats_individual]),
        player_2_id => clean_player(player_2) |> Map.drop([:stats_all, :stats_individual])
      })
    )
  end

  defp clean_players(players) do
    Enum.map(players, fn player ->
      clean_player(player)
    end)
  end

  defp clean_player(player) when not is_nil(player) do
    league =
      case player.league do
        %League{} = league ->
          Utils.struct_to_json_map(league, [:matches, :players])

        _ ->
          nil
      end

    Utils.struct_to_json_map(player, [:logs, :matches, :uploads, :permissions])
    |> Map.put(:league, league)
    |> Map.drop([:league_id])
  end

  defp clean_player(_), do: %{}

  defp clean_stat(stat) do
    Utils.struct_to_json_map(stat, [:player, :inserted_at, :updated_at])
  end
end
