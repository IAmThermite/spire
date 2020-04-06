defmodule Spire.SpireWeb.Api.PlayerController do
  use Spire.SpireWeb, :controller

  alias Spire.SpireDB.Players
  alias Spire.SpireDB.Players.Stats
  alias Spire.SpireDB.Leagues.League
  alias Spire.Utils

  def index(conn, %{"search" => search}) do
    players =
      Players.list_players("%#{String.trim(search)}%")
      |> clean_players()

    json(conn, players)
  end

  def index(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Please provide a search parameter"})
  end

  def show(conn, %{"id" => id}) do
    player =
      Players.get_by_steamid64(id)
      |> clean_stats()
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

          if modified_class != "" do
            get_stats_deltas_individual(player_1, player_2, modified_type, modified_class)
          else
            get_stats_deltas_all(player_1, player_2, modified_type)
          end

        _ ->
          get_stats_deltas_all(player_1, player_2, modified_type)

      end

    json(
      conn,
      Map.merge(stats, %{
        player_1_id =>
          player_1
          |> drop_stats()
          |> clean_player(),
        player_2_id =>
          player_2
          |> drop_stats()
          |> clean_player()
      })
    )
  end

  def compare(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Invalid parameters provided. See the API section on the About page for correct format."})
  end

  defp get_stats_deltas_all(player_1, player_2, type) do
    player_1_stats = Stats.get_stats_all(player_1, type)
    player_2_stats = Stats.get_stats_all(player_2, type)
    fields = Stats.get_stats_all_fields()
    deltas = Stats.get_deltas(player_1_stats, player_2_stats, fields)

    %{
      player_1_stats: clean_stat(player_1_stats),
      player_2_stats: clean_stat(player_2_stats),
      deltas: deltas
    }
  end

  defp get_stats_deltas_individual(player_1, player_2, type, class) do
    player_1_stats = Stats.get_stats_individual(player_1, type, class)
    player_2_stats = Stats.get_stats_individual(player_2, type, class)
    fields = Stats.Individual.fields_for_class(class)
    deltas = Stats.get_deltas(player_1_stats, player_2_stats, fields)

    %{
      player_1_stats: clean_stat(player_1_stats) |> Map.take(fields),
      player_2_stats: clean_stat(player_2_stats) |> Map.take(fields),
      deltas: Map.take(deltas, fields)
    }
  end

  defp clean_players(players) do
    Enum.map(players, fn player ->
      player
      |> Spire.SpireDB.Repo.preload([:stats_all, :stats_individual])
      |> clean_stats()
      |> clean_player()
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

  defp clean_player(_), do: nil

  defp clean_stat(stat)do
    Utils.struct_to_json_map(stat, [:player, :inserted_at, :updated_at])
  end

  defp clean_stats(%Players.Player{} = player) do
    stats_all =
      case player.stats_all do
        [_top | _tail] ->
          Enum.map(player.stats_all, fn stat ->
            clean_stat(stat)
          end)

        _ ->
          []
      end

    stats_individual =
      case player.stats_individual do
        [_top | _tail] ->
          Enum.map(player.stats_individual, fn stat ->
            clean_stat(stat)
          end)

        _ ->
          []
      end
    player
    |> Map.put(:stats_all, stats_all)
    |> Map.put(:stats_individual, stats_individual)
  end

  defp clean_stats(_), do: nil

  defp drop_stats(%Players.Player{} = player), do: Map.drop(player, [:stats_all, :stats_individual])

  defp drop_stats(_player), do: nil
end
