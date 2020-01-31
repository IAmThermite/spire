class StatsAll {
  constructor(stats) {
    this.total_kills = stats.total_kills || 0;
    this.total_deaths = stats.total_deaths || 0;
    this.total_assists = stats.total_assists || 0;
    this.total_damage = stats.total_damage || 0;
    this.total_healing = stats.total_healing || 0;
    this.total_captures = stats.total_captures || 0;
    
    this.longest_killstreak = stats.longest_killstreak || 0;
    
    this.average_dpm = stats.average_dpm || 0.0;
    
    this.times_seen_scout = stats.times_seen_scout || 0;
    this.times_seen_soldier = stats.times_seen_soldier || 0;
    this.times_seen_pyro = stats.times_seen_pyro || 0;
    this.times_seen_demoman = stats.times_seen_demoman || 0;
    this.times_seen_heavyweapons = stats.times_seen_heavyweapons || 0;
    this.times_seen_engineer = stats.times_seen_engineer || 0;
    this.times_seen_medic = stats.times_seen_medic || 0;
    this.times_seen_sniper = stats.times_seen_sniper || 0;
    this.times_seen_spy = stats.times_seen_spy || 0;
    
    this.number_of_logs = stats.number_of_logs || 0;
    this.time_played = stats.time_played || 0;
  }

  asArray = () => {
    return [
      this.total_kills,
      this.total_deaths,
      this.total_assists,
      this.total_damage,
      this.total_healing,
      this.total_captures,

      this.longest_killstreak,

      this.average_dpm,

      this.times_seen_scout,
      this.times_seen_soldier,
      this.times_seen_pyro,
      this.times_seen_demoman,
      this.times_seen_heavyweapons,
      this.times_seen_engineer,
      this.times_seen_medic,
      this.times_seen_sniper,
      this.times_seen_spy,

      this.number_of_logs,
      this.time_played,
    ]
  }

  toQuery = () => {
    return ""
  }
}

class StatsIndividual {
  constructor(stats) {
    this.kills = stats.kills || 0;
    this.deaths = stats.deaths || 0;
    this.assists = stats.assists || 0;
    this.dpm = stats.dpm || 0;
    this.dmg_total = stats.dmg_total || 0;
    this.heal_total = stats.heal_total || 0;

    this.kills_pri = stats.kills_pri || 0;
    this.shots_hit_pri = stats.shots_hit_pri || 0;
    this.shots_fired_pri = stats.shots_fired_pri || 0;
    this.accuracy_pri = stats.accuracy_pri || 0.0;
    this.dmg_per_shot_pri = stats.dmg_per_shot_pri || 0.0;

    this.kills_sec = stats.kills_sec || 0;
    this.shots_hit_sec = stats.shots_hit_sec || 0;
    this.shots_fired_sec = stats.shots_fired_sec || 0;
    this.accuracy_sec = stats.accuracy_sec || 0.0;
    this.dmg_per_shot_sec = stats.dmg_per_shot_sec || 0.0;

    this.airshots = stats.airshots  || 0;
    this.headshots = stats.headshots || 0;
    this.backstabs = stats.backstabs || 0;
    this.medics_dropped = stats.medics_dropped || 0;
    this.reflect_kills = stats.reflect_kills || 0;

    this.ubers = stats.ubers || 0;
    this.kritz = stats.kritz || 0;
    this.drops = stats.drops || 0;
    this.ave_time_to_build = stats.ave_time_to_build || 0.0;
    this.ave_uber_length = stats.ave_uber_length || 0.0;
    this.ave_time_before_healing = stats.ave_time_before_healing || 0.0;
    this.ave_time_before_using = stats.ave_time_before_using || 0.0;

    this.total_playtime = stats.total_playtime || 0;
    this.number_of_logs = stats.number_of_logs || 0;
  }

  asArray = () => {
    return [
      this.kills,
      this.deaths,
      this.assists,
      this.dpm,
      this.dmg_total,

      this.shots_hit_pri,
      this.shots_fired_pri,
      this.accuracy_pri,
      this.dmg_per_shot_pri,

      this.shots_hit_sec,
      this.shots_fired_sec,
      this.accuracy_sec,
      this.dmg_per_shot_sec,

      this.airshots,
      this.headshots,
      this.backstabs,
      this.medics_dropped,
      this.reflect_kills,

      this.ubers,
      this.kritz,
      this.drops,
      this.ave_time_to_build,
      this.ave_uber_length,
      this.ave_time_before_healing,
      this.ave_time_before_using,
      
      this.total_playtime,
      this.number_of_logs,
    ];
  }

  toQuery = () => {
    return ""
  }
}

module.exports = {StatsAll, StatsIndividual};