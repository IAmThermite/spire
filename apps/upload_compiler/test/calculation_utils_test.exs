defmodule Spire.UploadCompiler.CalculationUtilsTest do
  use ExUnit.Case
  doctest Spire.UploadCompiler.CalculationUtils

  alias Spire.UploadCompiler.CalculationUtils
  alias Spire.SpireDB.Players.Stats.AllTotal

  describe "add_stat/3" do
    test "it should add to stats" do
      stats = %AllTotal{total_kills: 10}

      new_stats = CalculationUtils.add_stat(stats, :total_kills, 5)

      assert new_stats.total_kills == 15
    end

    test "it should add to stats when stat is 0" do
      stats = %AllTotal{}

      new_stats = CalculationUtils.add_stat(stats, :total_kills, 5)

      assert new_stats.total_kills == 5
    end
  end

  describe "average_stat/3" do
    test "it should average out two stats" do
      stats = %AllTotal{average_dpm: 100}

      new_stats = CalculationUtils.average_stat(stats, :average_dpm, 150)

      assert new_stats.average_dpm == 125
    end

    test "it should average out two stats 2" do
      stats = %AllTotal{average_dpm: 150}

      new_stats = CalculationUtils.average_stat(stats, :average_dpm, 100)

      assert new_stats.average_dpm == 125
    end

    test "it should put the value directly when stat is 0" do
      stats = %AllTotal{}

      new_stats = CalculationUtils.average_stat(stats, :average_dpm, 150)

      assert new_stats.average_dpm == 150
    end
  end
end
