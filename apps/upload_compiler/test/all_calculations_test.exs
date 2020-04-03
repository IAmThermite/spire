defmodule Spire.UploadCompiler.AllCalculationsTest do
  use ExUnit.Case
  doctest Spire.UploadCompiler.AllCalculations

  alias Spire.UploadCompiler.AllCalculations
  alias Spire.SpireDB.Players.Stats.All

  @class_stat %{
    "type" => "soldier",
    "kills" => 10,
    "deaths" => 10,
    "assists" => 10,
    "dmg" => 9000,
    "total_time" => 1800,
    "weapon" => %{
      "tf_projectile_rocket" => %{
        "kills" => 9,
        "dmg" => 8000,
        "avg_dmg" => 60,
        "shots" => 100,
        "hits" => 70
      },
      "shotgun_soldier" => %{
        "kills" => 1,
        "dmg" => 1000,
        "avg_dmg" => 60,
        "shots" => 10,
        "hits" => 7
      }
    }
  }

  @log_json %{
    "kills" => 10,
    "deaths" => 10,
    "assists" => 10,
    "dmg" => 9000,
    "dapm" => 300,
    "lks" => 3,
    "cpc" => 5,
    "class_stats" => [
      @class_stat
    ],
    "ubertypes" => %{
      "medigun" => 10,
      "kritzkrieg" => 1
    },
    "drops" => 2,
    "heal" => 1000,
    "medicstats" => %{
      "deaths_with_95_99_uber" => 0,
      "advantages_lost" => 0,
      "biggest_advantage_lost" => 0,
      "deaths_within_20s_after_uber" => 3,
      "avg_time_before_healing" => 2.5,
      "avg_time_to_build" => 65,
      "avg_time_before_using" => 15,
      "avg_uber_length" => 7.5
    },
    "as" => 5,
    "headshots" => 3,
    "backstabs" => 3
  }

  describe "calculate_general_stats/2" do
    test "it should add general stats" do
      stats = %All{}

      new_stats = AllCalculations.calculate_general_stats(stats, @log_json)

      assert new_stats.total_kills == 10
      assert new_stats.total_deaths == 10
      assert new_stats.total_assists == 10
      assert new_stats.total_damage == 9000
      assert new_stats.total_healing == 1000
      assert new_stats.average_dpm == 300
      assert new_stats.total_captures == 5
      assert new_stats.longest_ks == 3
    end

    test "it should add when stats already exist" do
      stats = %All{
        total_kills: 4,
        total_assists: 4,
        total_deaths: 4,
        total_damage: 3000,
        total_healing: 3000,
        average_dpm: 250,
        total_captures: 3,
        longest_ks: 3
      }

      new_stats = AllCalculations.calculate_general_stats(stats, @log_json)

      assert new_stats.total_kills == 14
      assert new_stats.total_deaths == 14
      assert new_stats.total_assists == 14
      assert new_stats.total_damage == 12000
      assert new_stats.total_healing == 4000
      assert new_stats.average_dpm == 275
      assert new_stats.total_captures == 8
      assert new_stats.longest_ks == 3
    end

    test "it should not change longest_ks when ks in logs is lower" do
      stats = %All{longest_ks: 5}

      new_stats = AllCalculations.calculate_general_stats(stats, @log_json)

      assert new_stats.longest_ks == 5
    end
  end

  describe "calculate_seen_stats/2" do
    test "it should add the number of times seen for each class" do
      stats = %All{}

      new_stats = AllCalculations.calculate_seen_stats(stats, [@class_stat])

      assert new_stats.times_seen_soldier == 1
    end

    test "it should add the number of times seen for each class 2" do
      stats = %All{times_seen_soldier: 2}

      new_stats = AllCalculations.calculate_seen_stats(stats, [@class_stat])

      assert new_stats.times_seen_soldier == 3
    end

    test "it should add the number of times seen for multiple classes" do
      class_stats = [
        @class_stat,
        @class_stat
        |> Map.put("type", "scout")
      ]

      stats = %All{times_seen_soldier: 2, times_seen_scout: 4}

      new_stats = AllCalculations.calculate_seen_stats(stats, class_stats)

      assert new_stats.times_seen_soldier == 3
      assert new_stats.times_seen_scout == 5
    end
  end

  describe "calculate_additional_stats/2" do
    test "adds total time played" do
      class_stats = [
        @class_stat,
        @class_stat
        |> Map.put("type", "scout")
        |> Map.put("total_time", 1500)
      ]

      stats = %All{}

      new_stats = AllCalculations.calculate_additional_stats(stats, class_stats)

      assert new_stats.time_played == 3300
      assert new_stats.number_of_logs == 1
    end

    test "adds total time played 2" do
      class_stats = [
        @class_stat,
        @class_stat
        |> Map.put("type", "scout")
        |> Map.put("total_time", 1500)
      ]

      stats = %All{time_played: 4000, number_of_logs: 3}

      new_stats = AllCalculations.calculate_additional_stats(stats, class_stats)

      assert new_stats.time_played == 7300
      assert new_stats.number_of_logs == 4
    end
  end

  describe "calculate_stats/2" do
    test "calculates total stats" do
      stats = %All{}

      new_stats = AllCalculations.calculate_stats(stats, @log_json)

      refute new_stats.total_kills == 0
      refute new_stats.time_played == 0
      refute new_stats.number_of_logs == 0
    end
  end
end
