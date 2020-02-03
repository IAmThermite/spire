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

  toQuery = (real) => {
    return `
      UPDATE stats_all_${real ? 'real' : 'total'}
      SET
      total_kills=$1, total_deaths=$2, total_assists=$3, total_damage=$4, total_healing=$5, total_captures=$6,
      longest_ks=$7,
      average_dpm=$8,
      times_seen_scout=$9, times_seen_soldier=$10, times_seen_pyro=$11, times_seen_demoman=$12,
      times_seen_heavyweapons=$13, times_seen_engineer=$14, times_seen_medic=$15, times_seen_sniper=$16, times_seen_spy=$17,
      number_of_logs=$18, time_played=$19,
      updated_at=$20
      WHERE player_id=$21
    `;
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
      this.heal_total,

      this.kills_pri,
      this.shots_hit_pri,
      this.shots_fired_pri,
      this.accuracy_pri,
      this.dmg_per_shot_pri,

      this.kills_sec,
      this.shots_hit_sec,
      this.shots_fired_sec,
      this.accuracy_sec,
      this.dmg_per_shot_sec,

      this.airshots,
      this.headshots,
      this.backstabs,
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

  toQuery = (real) => {
    const query = `
      UPDATE stats_individual_${real ? 'real' : 'total'}
      SET
      kills=$1, deaths=$2, assists=$3, dpm=$4, dmg_total=$5, heal_total=$6,
      kills_pri=$7, shots_hit_pri=$8, shots_fired_pri=$9, accuracy_pri=$10, dmg_per_shot_pri=$11,
      kills_sec=$12, shots_hit_sec=$13, shots_fired_sec=$14, accuracy_sec=$15, dmg_per_shot_sec=$16,
      airshots=$17, headshots=$18, backstabs=$19, reflect_kills=$20,
      ubers=$21, kritz=$22, drops=$23, ave_time_to_build=$24, ave_uber_length=$25, ave_time_before_healing=$26, ave_time_before_using=$27,
      total_playtime=$28, number_of_logs=$29,
      updated_at=$30
      WHERE player_id=$31 AND class=$32
    `
    return query;
  }
}

module.exports = {StatsAll, StatsIndividual};