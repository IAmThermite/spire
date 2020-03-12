defmodule Spire.UploadCompiler.AllCalculations do
  def calculate_stats(stats_all, log_json) do
    stats_all
    |> calculate_general_stats(log_json)
  end

  def calculate_general_stats(stats_all, log_json) do
    stats_all
  end
end
