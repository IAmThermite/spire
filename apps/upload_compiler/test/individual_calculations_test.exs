defmodule Spire.UploadCompiler.IndividualCalculationsTest do
  use ExUnit.Case
  doctest Spire.UploadCompiler.IndividualCalculations

  alias Spire.UploadCompiler.IndividualCalculations
  alias Spire.SpireDB.Players.Stats.Individual

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
      },
      "deflect_rocket" => %{
        "kills" => 1,
        "dmg" => 1000,
        "avg_dmg" => 60,
        "shots" => 10,
        "hits" => 7
      }
    }
  }

  @log_json %{
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
      stats = %Individual{}

      new_stats = IndividualCalculations.calculate_general_stats(stats, @class_stat)

      assert new_stats.kills == 10
      assert new_stats.deaths == 10
      assert new_stats.assists == 10
      assert new_stats.dmg_total == 9000
      assert new_stats.dpm == 300
    end

    test "it should add general stats when stats are non 0" do
      stats = %Individual{kills: 5, deaths: 5, assists: 5, dpm: 200}

      new_stats = IndividualCalculations.calculate_general_stats(stats, @class_stat)

      assert new_stats.kills == 15
      assert new_stats.deaths == 15
      assert new_stats.assists == 15
      assert new_stats.dpm == 250
    end
  end

  describe "calculate_weapon_stats/2" do
    test "it adds weapon stats" do
      stats = %Individual{}

      new_stats = IndividualCalculations.calculate_weapon_stats(stats, @class_stat)

      assert new_stats.kills_pri == 9
      assert new_stats.dmg_pri == 8000
      assert new_stats.shots_hit_pri == 70
      assert new_stats.shots_fired_pri == 100
      assert new_stats.accuracy_pri == 70
      assert new_stats.dmg_per_shot_pri == 60
    end

    test "it adds weapon stats when stats are non 0" do
      stats = %Individual{
        kills_pri: 5,
        dmg_pri: 5000,
        shots_hit_pri: 20,
        shots_fired_pri: 50,
        accuracy_pri: 40.0
      }

      new_stats = IndividualCalculations.calculate_weapon_stats(stats, @class_stat)

      assert new_stats.kills_pri == 14
      assert new_stats.dmg_pri == 13000
      assert new_stats.shots_hit_pri == 90
      assert new_stats.shots_fired_pri == 150
      assert new_stats.accuracy_pri == 60
      assert new_stats.dmg_per_shot_pri == 60
    end

    test "it adds multiple weapon stats" do
      weapons =
        @class_stat["weapon"]
        |> Map.put("quake_rl", %{
          "kills" => 10,
          "dmg" => 2000,
          "avg_dmg" => 90,
          "shots" => 200,
          "hits" => 170
        })

      class_stats =
        @class_stat
        |> Map.put("weapon", weapons)

      stats = %Individual{}

      new_stats = IndividualCalculations.calculate_weapon_stats(stats, class_stats)

      assert new_stats.kills_pri == 19
      assert new_stats.dmg_pri == 10000
      assert new_stats.shots_hit_pri == 240
      assert new_stats.shots_fired_pri == 300
      assert new_stats.accuracy_pri == 80
      assert new_stats.dmg_per_shot_pri == 75
    end
  end

  describe "calculate_medic_stats/2" do
    test "it does nothing when class is not medic" do
      stats = %Individual{class: "soldier"}

      new_stats = IndividualCalculations.calculate_medic_stats(stats, @log_json)

      assert new_stats.ubers == 0
    end

    test "it should calculate the number of ubers and kritz" do
      stats = %Individual{class: "medic"}

      new_stats = IndividualCalculations.calculate_medic_stats(stats, @log_json)

      assert new_stats.ubers == 10
      assert new_stats.kritz == 1
    end

    test "it should add the other stats" do
      stats = %Individual{class: "medic"}

      new_stats = IndividualCalculations.calculate_medic_stats(stats, @log_json)

      assert new_stats.heal_total == 1000
      assert new_stats.ave_time_to_build == 65
      assert new_stats.drops == 2
      assert new_stats.ave_uber_length == 7.5
      assert new_stats.ave_time_before_healing == 2.5
      assert new_stats.ave_time_before_using == 15
    end

    test "it should add the other stats when stats already exist" do
      stats = %Individual{
        class: "medic",
        heal_total: 2000,
        ave_time_to_build: 55,
        drops: 1,
        ave_uber_length: 7,
        ave_time_before_healing: 2,
        ave_time_before_using: 20
      }

      new_stats = IndividualCalculations.calculate_medic_stats(stats, @log_json)

      assert new_stats.heal_total == 3000
      assert new_stats.ave_time_to_build == 60
      assert new_stats.drops == 3
      assert new_stats.ave_uber_length == 7.25
      assert new_stats.ave_time_before_healing == 2.25
      assert new_stats.ave_time_before_using == 17.5
    end
  end

  describe "calculate_soldier_demoman_stats/2" do
    test "does nothing when class is not soldier or demoman" do
      stats = %Individual{class: "medic"}

      new_stats = IndividualCalculations.calculate_soldier_demoman_stats(stats, @log_json)

      assert new_stats.airshots == 0
    end

    test "it should add airshots when class is soldier" do
      stats = %Individual{class: "soldier"}

      new_stats = IndividualCalculations.calculate_soldier_demoman_stats(stats, @log_json)

      assert new_stats.airshots == 5
    end

    test "it should add airshots when class is demoman" do
      stats = %Individual{class: "demoman"}

      new_stats = IndividualCalculations.calculate_soldier_demoman_stats(stats, @log_json)

      assert new_stats.airshots == 5
    end
  end

  describe "calculate_sniper_stats/2" do
    test "it should do nothing if class is not sniper" do
      stats = %Individual{class: "soldier"}

      new_stats = IndividualCalculations.calculate_sniper_stats(stats, @log_json)

      assert new_stats.headshots == 0
    end

    test "it should add headshots if class is sniper" do
      stats = %Individual{class: "sniper"}

      new_stats = IndividualCalculations.calculate_sniper_stats(stats, @log_json)

      assert new_stats.headshots == 3
    end
  end

  describe "calculate_spy_stats/2" do
    test "it should do nothing if class is not spy" do
      stats = %Individual{class: "soldier"}

      new_stats = IndividualCalculations.calculate_spy_stats(stats, @log_json)

      assert new_stats.backstabs == 0
    end

    test "it should add headshots if class is spy" do
      stats = %Individual{class: "spy"}

      new_stats = IndividualCalculations.calculate_spy_stats(stats, @log_json)

      assert new_stats.backstabs == 3
    end
  end

  describe "calculate_pyro_stats/2" do
    test "it should add to reflect_kills when weapon is present" do
      stats = %Individual{class: "pyro"}

      new_stats = IndividualCalculations.calculate_pyro_stats(stats, @class_stat["weapon"])

      assert new_stats.reflect_kills == 1
    end
  end

  describe "calculate_stats/2" do
    test "it should calculate stats" do
      stats = %Individual{class: "soldier"}

      new_stats = IndividualCalculations.calculate_stats(stats, @log_json)

      refute new_stats.kills == 0
      refute new_stats.accuracy_pri == 0
      refute new_stats.airshots == 0
      refute new_stats.kills_pri == 0
      refute new_stats.kills_sec == 0
      refute new_stats.total_playtime == 0
    end
  end
end
