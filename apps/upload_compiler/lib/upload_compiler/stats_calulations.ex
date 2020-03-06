defmodule Spire.UploadCompiler.StatsCalculations do
  def calculate_stats_all(stats_all, log_json) do
    stats_all
    |> calculate_stats_all(log_json)
  end

  def calculate_stats_individual(stats_individual, log_json) do
    stats_individual
    |> calculate_stats_individual(log_json)
  end

  def calculate_general_stats_all(stats_all, log_json) do
    stats_all
  end

  def calculate_general_stats_individual(stats_individual, log_json) do
    stats_individual
  end
end
