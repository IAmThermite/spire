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

        is_admin?(conn) ->
          true

        true ->
          false
      end
    else
      false
    end
  end

  def is_admin?(conn) do
    Spire.SpireWeb.PermissionsHelper.is_logged_in?(conn) and
      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin)
  end

  def get_stats_map(stats_individual, stats_all) do
    {individual_real, individual_total} = Enum.split_with(stats_individual, fn stat ->
      stat.real
    end)

    sorted_individual_real = sort_individual_stats(individual_real)

    sorted_individual_total = sort_individual_stats(individual_total)

    all = Enum.reduce(stats_all, %{}, fn %{real: real} = stat, acc ->
      type =
        if real do
          "stats_all_real"
        else
          "stats_all_total"
        end

      Map.put(acc, type, stat)
    end)

    all
    |> Map.put("stats_individual_real", sorted_individual_real)
    |> Map.put("stats_individual_total", sorted_individual_total)
  end

  defp sort_individual_stats(stats) do
    Enum.sort(stats, fn curr, prev ->
      @stats_order[curr.class] < @stats_order[prev.class]
    end)
  end
end
