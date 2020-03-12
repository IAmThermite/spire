defmodule Spire.UploadCompiler.IndividualCalculations do
  require Logger

  alias Spire.UploadCompiler.CalculationUtils, as: Utils

  def calculate_stats(stats_individual, log_json) do
    log_data = get_log_data_for_class(stats_individual.changes.class, log_json)

    stats_individual
    |> calculate_general_stats(log_data)
    |> calculate_weapon_stats(log_data)
    |> calculate_medic_stats(log_json)
    |> calculate_soldier_demoman_stats(log_json)
    |> calculate_sniper_stats(log_json)
    |> calculate_spy_stats(log_json)
    |> Utils.add_stat(:total_playtime, log_data["total_time"])
    |> Utils.add_stat(:number_of_logs, 1)

    # |> calculate_pyro_stats(log_data)
  end

  def calculate_general_stats(stats_individual, log_data) do
    %{
      "kills" => kills,
      "assists" => assists,
      "deaths" => deaths,
      "dmg" => damage,
      "total_time" => total_time
    } = log_data

    dpm = damage / total_time

    stats_individual
    |> Utils.add_stat(:kills, kills)
    |> Utils.add_stat(:assists, assists)
    |> Utils.add_stat(:deaths, deaths)
    |> Utils.average_stat(:dpm, dpm)
  end

  # TODO: does this function work as expected?
  def calculate_weapon_stats(stats_individual, log_data) do
    weapon_list = Enum.to_list(log_data["weapon"])

    Enum.reduce(weapon_list, stats_individual, fn {weapon, stats}, changeset ->
      add_weapon_stats(changeset, weapon, stats)
    end)
  end

  defp add_weapon_stats(stats_individual, weapon, weapon_stats) do
    %{"kills" => kills, "dmg" => damage, "avg_dmg" => ave_dmg, "shots" => shots, "hits" => hits} =
      weapon_stats

    cond do
      weapon in Utils.primary_weapons() ->
        # TODO: special case for pyro required
        stats_individual
        |> Utils.add_stat(:kills_pri, kills)
        |> Utils.add_stat(:dmg_pri, damage)
        |> Utils.average_stat(:accuracy_pri, hits / shots * 100)
        |> Utils.average_stat(:dmg_per_shot_pri, ave_dmg)
        |> Utils.add_stat(:shots_hit_pri, hits)
        |> Utils.add_stat(:shots_fired_pri, shots)

      weapon in Utils.secondary_weapons() ->
        stats_individual
        |> Utils.add_stat(:kills_sec, kills)
        |> Utils.add_stat(:dmg_sec, damage)
        |> Utils.average_stat(:accuracy_sec, hits / shots * 100)
        |> Utils.average_stat(:dmg_per_shot_sec, ave_dmg)
        |> Utils.add_stat(:shots_hit_sec, hits)
        |> Utils.add_stat(:shots_fired_sec, shots)

      true ->
        Logger.warn("Unknown weapon found #{weapon}, probably just meele")
        stats_individual
    end
  end

  def calculate_medic_stats(%{class: class} = stats_individual, log_json) when class == "medic" do
    %{"medicstats" => medicstats} = log_json

    stats_individual
    |> add_kritz_stat(log_json["ubertypes"])
    |> add_uber_stat(log_json["ubertypes"])
    |> Utils.add_stat(:heal_total, log_json["heal_total"])
    |> Utils.average_stat(:ave_time_to_build, medicstats["avg_time_to_build"])
    |> Utils.add_stat(:drops, log_json["drops"])
    |> Utils.average_stat(:ave_uber_length, medicstats["avg_uber_length"])
    |> Utils.average_stat(:ave_time_before_healing, medicstats["avg_time_before_healing"])
    |> Utils.average_stat(:ave_time_before_using, medicstats["avg_time_before_using"])
  end

  def calculate_medic_stats(stats_individual, _log_json), do: stats_individual

  defp add_kritz_stat(stats_individual, %{"kritzkrieg" => kritz} = _ubertypes) do
    Utils.add_stat(stats_individual, :kritz, kritz)
  end

  defp add_kritz_stat(stats_individual, _ubertypes) do
    stats_individual
  end

  defp add_uber_stat(stats_individual, %{"medigun" => ubers} = _ubertypes) do
    Utils.add_stat(stats_individual, :ubers, ubers)
  end

  defp add_uber_stat(stats_individual, _ubertypes) do
    stats_individual
  end

  def calculate_soldier_demoman_stats(
        %{class: class} = stats_individual,
        %{"as" => airshots} = _log_json
      )
      when class == "soldier" or class == "demoman" do
    Utils.add_stat(stats_individual, :airshots, airshots)
  end

  def calculate_soldier_demoman_stats(stats_individual, _log_json), do: stats_individual

  def calculate_sniper_stats(
        %{class: class} = stats_individual,
        %{"headshots" => headshots} = _log_json
      )
      when class == "sniper" do
    Utils.add_stat(stats_individual, :headshots, headshots)
  end

  def calculate_sniper_stats(stats_individual, _log_json), do: stats_individual

  def calculate_spy_stats(
        %{class: class} = stats_individual,
        %{"backstabs" => backstabs} = _log_json
      )
      when class == "spy" do
    Utils.add_stat(stats_individual, :backstabs, backstabs)
  end

  def calculate_spy_stats(stats_individual, _log_json), do: stats_individual

  defp get_log_data_for_class(class, log_json) do
    [log_data | _tail] =
      Enum.filter(log_json["class_stats"], fn stat ->
        stat["type"] == class
      end)

    log_data
  end
end
