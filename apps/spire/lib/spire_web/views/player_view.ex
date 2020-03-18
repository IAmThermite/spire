defmodule Spire.SpireWeb.PlayerView do
  use Spire.SpireWeb, :view

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
    |> Map.put("stats_individual_real", individual_real)
    |> Map.put("stats_individual_total", individual_total)
  end
end
