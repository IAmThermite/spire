defmodule Spire.UploadCompiler.AllCalculations do
  require Logger

  alias Spire.UploadCompiler.CalculationUtils, as: Utils

  def calculate_stats(stats_all, log_json) do
    %{"class_stats" => class_stats} = log_json

    stats_all
    |> calculate_general_stats(log_json)
    |> calculate_seen_stats(class_stats)
    |> calculate_additional_stats(class_stats)
  end

  def calculate_general_stats(stats_all, log_json) do
    %{
      "kills" => kills,
      "assists" => assists,
      "deaths" => deaths,
      "dmg" => damage,
      "dapm" => dpm,
      "lks" => longest_ks,
      "heal" => healing,
      "cpc" => control_points
    } = log_json

    killstreak =
      if longest_ks > stats_all.longest_ks do
        longest_ks
      else
        stats_all.longest_ks
      end

    stats_all
    |> Utils.add_stat(:total_kills, kills)
    |> Utils.add_stat(:total_assists, assists)
    |> Utils.add_stat(:total_deaths, deaths)
    |> Utils.add_stat(:total_damage, damage)
    |> Utils.add_stat(:total_healing, healing)
    |> Utils.add_stat(:total_captures, control_points)
    |> Utils.average_stat(:average_dpm, dpm)
    |> Utils.put_stat(:longest_ks, killstreak)
  end

  def calculate_seen_stats(stats_all, class_stats) do
    Enum.reduce(class_stats, stats_all, fn class, acc ->
      # for some reason a log returned type=undefined http://logs.tf/json/2496503
      if class["type"] != "undefined" do
        stat = String.to_existing_atom("times_seen_" <> class["type"])

        acc
        |> Utils.add_stat(stat, 1)
      else
        acc
      end
    end)
  end

  def calculate_additional_stats(stats_all, class_stats) do
    Enum.reduce(class_stats, stats_all, fn stat, acc ->
      acc
      |> Utils.add_stat(:time_played, stat["total_time"])
    end)
    |> Utils.add_stat(:number_of_logs, 1)
  end
end
