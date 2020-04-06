defmodule Spire.SpireWeb.PlayerView do
  use Spire.SpireWeb, :view

  @stats_order %{
    "scout" => 1,
    "soldier" => 2,
    "pyro" => 3,
    "demoman" => 4,
    "heavyweapons" => 5,
    "engineer" => 6,
    "medic" => 7,
    "sniper" => 8,
    "spy" => 9
  }

  def can_manage?(conn, id) do
    if Spire.SpireWeb.PermissionsHelper.is_logged_in?(conn) do
      cond do
        id == conn.assigns[:user].id ->
          true

        Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_users) ->
          true

        true ->
          false
      end
    else
      false
    end
  end

  def is_admin?(conn) do
    Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin)
  end

  def get_stats_map(stats_individual, stats_all) do
    individual_match =
      Enum.filter(stats_individual, fn stats ->
        stats.type == "MATCH"
      end)

    individual_other =
      Enum.filter(stats_individual, fn stats ->
        stats.type == "OTHER"
      end)

    sorted_individual_match = sort_individual_stats(individual_match)

    sorted_individual_other = sort_individual_stats(individual_other)

    all =
      Enum.reduce(stats_all, %{}, fn %{type: type} = stat, acc ->
        type =
          case type do
            "MATCH" ->
              "stats_all_match"

            "OTHER" ->
              "stats_all_other"

            _ ->
              "stats_all_combined"
          end

        Map.put(acc, type, stat)
      end)

    all
    |> Map.put("stats_individual_match", sorted_individual_match)
    |> Map.put("stats_individual_other", sorted_individual_other)
  end

  defp sort_individual_stats(stats) do
    Enum.sort(stats, fn curr, prev ->
      @stats_order[curr.class] < @stats_order[prev.class]
    end)
  end
end
