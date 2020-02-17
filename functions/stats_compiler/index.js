const fetch = require('node-fetch');
const db = require('./db');
const {StatsAll, StatsIndividual} = require('./stats');

const primaryWeapons = [
  'scattergun',
  'tf_projectile_rocket',
  'quake_rl',
  'rockerlauncher_directhit',
  'liberty_launcher', // ?
  'blackbox',
  'dumpster_device', // beggars
  'airstrike', // ?
  'flamethrower',
  'degreaser',
  'backburner', // ?
  'tf_projectile_pipe',
  'iron_bomber',
  'loch_n_load', // ?
  'minigun',
  'tomislav',
  'brass_beast',
  'iron_curtain',
  'long_heatmaker',
  'shotgun_primary',
  'frontier_justice',
  'widowmaker',
  'crusaders_crossbow',
  'snipperrifle',
  'awper_hand',
  'revolver',
  'ambassador',
  'enforcer',
];
const secondaryWeapons = [
  'scout_pistol',
  'pep_pistol', // pretty boys? capper?
  'max_gun',
  'shotgun_soldier',
  'flaregun',
  'shotgun_pyro',
  'tf_projectile_pipe_remote',
  'quickiebomb_launcher',
  'shotgun_heavy',
  'family_buisness', // ?
  'pistol',
  'smg',
];

const queries = [];

exports.handler = async (event) => {
  main()
};

// TOTAL STATS \\
/**
 * Calculate stats for everything
 * @param {Object} player the player object
 * @param {String} steamid steamid of player
 * @param {Object} logData the raw json log data
 * @param {Boolean} real is the log for a match
 */
const calculateStatsAll = async (player, steamid, logData, real) => {
  await ensureStatsAllExist(player, real);
  const stats = new StatsAll(getStatsAll(player, real));

  calculateTotalStats(stats, logData)

  calculateSeenStats(stats, logData);

  calculateTimePlayedStats(stats, logData);

  return stats;
}

/**
 * Calculate stats based on totals
 * @param {StatsAll} stats stats current player stats
 * @param {Object} logData the log stats
 */
const calculateTotalStats = (stats, logData) => {
  stats.total_kills += logData.kills;
  stats.total_deaths += logData.deaths;
  stats.total_assists += logData.assists;
  stats.total_damage += logData.dmg;
  stats.total_healing += logData.heal;
  stats.total_captures += logData.cpc;

  stats.longest_killstreak = logData.lks > stats.longest_killstreak ? logData.lks : stats.longest_killstreak;

  if (stats.average_dpm === 0) {
    stats.average_dpm = logData.dapm;
  } else {
    stats.average_dpm = (logData.dapm + stats.average_dpm) / 2;
  }

  return stats;
}

/**
 * Calculate how many times player has played class
 * @param {StatsAll} stats stats current player stats
 * @param {Object} logData the log stats
 */
const calculateSeenStats = (stats, logData) => {
  const classesPlayed = logData.class_stats.map(stat => {
    return stat.type;
  });
  stats.times_seen_scout += classesPlayed.includes('scout') ? 1 : 0;
  stats.times_seen_soldier += classesPlayed.includes('soldier') ? 1 : 0;
  stats.times_seen_pyro += classesPlayed.includes('pyro') ? 1 : 0;
  stats.times_seen_demoman += classesPlayed.includes('demoman') ? 1 : 0;
  stats.times_seen_heavyweapons += classesPlayed.includes('heavyweapons') ? 1 : 0;
  stats.times_seen_engineer += classesPlayed.includes('engineer') ? 1 : 0;
  stats.times_seen_medic += classesPlayed.includes('medic') ? 1 : 0;
  stats.times_seen_sniper += classesPlayed.includes('sniper') ? 1 : 0;
  stats.times_seen_spy += classesPlayed.includes('spy') ? 1 : 0;

  stats.number_of_logs += 1;
  
  return stats;
}

/**
 * Calculate the time that the player played
 * @param {StatsAll} stats stats current player stats
 * @param {Object} logData the log stats
 */
const calculateTimePlayedStats = (stats, logData) => {
  let timePlayed = 0;
  logData.class_stats.forEach(stat => {
    timePlayed += stat.total_time;
  });
  stats.time_played += timePlayed;

  return stats;
}

// INDIVIDUAL STATS \\
/**
 * Calculate stats for each class
 * @param {Object} player the player object
 * @param {String} steamid steamid of player
 * @param {Object} logData the raw json log data
 * @param {Boolean} real is the log for a match
 */
const calculateStatsIndividual = async (player, steamid, logData, real) => {
  await ensureStatsIndividualExist(player, real);
  
  const individualClassStats = logData.class_stats.map(stats => {
    let stat = {};
    stat[stats.type] = stats; // get each classes stats
    return stat;
  });

  const stats = [];
  Object.keys(individualClassStats).forEach(className => {
    logStats = individualClassStats[className];
    stat = calculateStatsForClass(player, logStats, className, real);

    // calculate stats that should probably be in the individual
    // class stats but are not i.e airshots, headshots medic etc.
    if (className === "soldier" || className === "demoman") {
      stat.airshots += log.players[steamid].class_stats.airshots;
    }
    if (className === "sniper") {
      stat.headshots += log.players[steamid].class_stats.headshots_hit;
    }
    if (className === "spy") {
      // don't track headshots for spy
      stat.backstabs += log.players[steamid].class_stats.backstabs;
    }
    // calculate medic stats
    if (className === "medic") {
      calculateMedicStats(stats, logData);
    }

    stats.push([stat, className]);
  });

  return stats;
}

/**
 * Calculate stats for a single class
 * @param {Object} player the player object
 * @param {String} steamid steamid of player
 * @param {Object} logData the raw json log data
 * @param {Boolean} real is the log for a match
 * @returns {StatsIndividual} updated stats
 */
const calculateStatsForClass = async (player, logStats, className, real) => {
  await ensureStatsIndividualExist(player, className, real)

  const stats = new StatsIndividual(getStatsIndividual(player, className, real));
  
  // calculate generic stats
  calculateGenericStats(stats, logStats);
  // weapon stats
  calculateWeaponStats(stats, logStats);

  if (className === "pyro") {
    calculatePyroStats(stats, logStats);
  }

  return stats;
}

/**
 * Calculate generic stats for a single class
 * @param {StatsIndividual} stats current player stats
 * @param {Object} logStats the log stats
 */
const calculateGenericStats = (stats, logStats) => {
  stats.kills += logStats.kills
  stats.deaths += logStats.deaths;
  stats.assists += logStats.assists;

  if (stats.dpm === 0) {
    stats.dpm = logStats.dmg/(logStats.total_time/60);
  } else {
    stats.dpm = ((logStats.dmg/(logStats.total_time/60)) + stats.dpm) / 2;
  }

  stats.dmg_total += logStats.dmg;
  stats.heal_total += logStats.heal;

  stats.number_of_logs += 1;
  stats.total_playtime += logStats.total_time;

  return stats;
}

/**
 * Calculate weapon stats for a single class
 * @param {StatsIndividual} stats current player stats
 * @param {Object} logStats the log stats
 */
const calculateWeaponStats = (stats, logStats) => {
  Object.keys(logStats.weapon).forEach(weapon => {
    const weaponStats = logStats.weapon[weapon];
    if (primaryWeapons.includes(weapon)) {
      stats.shots_fired_pri += weaponStats.shots;
      stats.shots_hit_pri += weaponStats.hits;
      stats.kills_pri += weaponStats.kills;
      
      if (stats.accuracy_pri === 0) {
        stats.accuracy_pri = (weaponStats.hits / weaponStats.shots) * 100
      } else {
        stats.accuracy_pri = (stats.accuracy_pri + (weaponStats.shots / weaponStats.hit) * 100) / 2;
      }

      if (stats.dmg_per_shot_pri === 0) {
        stats.dmg_per_shot_pri = weaponStats.avg_dmg;
      } else {
        stats.dmg_per_shot_pri = (stats.dmg_per_shot_pri + weaponStats.avg_dmg) / 2;
      }
    } else if (secondaryWeapons.includes(weapon)) {
      stats.shots_fired_sec += weaponStats.shots;
      stats.shots_hit_sec += weaponStats.hits;
      stats.kills_sec += weaponStats.kills;
      
      if (stats.accuracy_sec === 0) {
        stats.accuracy_sec = (weaponStats.hits / weaponStats.shots) * 100
      } else {
        stats.accuracy_sec = (stats.accuracy_sec + (weaponStats.shots / weaponStats.hits) * 100) / 2;
      }

      if (stats.dmg_per_shot_sec === 0) {
        stats.dmg_per_shot_sec = weaponStats.avg_dmg;
      } else {
        stats.dmg_per_shot_sec = (stats.dmg_per_shot_sec + weaponStats.avg_dmg) / 2;
      }
    }
  });

  return stats;
}

/**
 * Calculate Medic stats
 * @param {StatsIndividual} stats current player stats
 * @param {Object} logStats the log stats
 */
const calculateMedicStats = (stats, logStats) => {
  stats.ubers += logStats.ubertypes.medigun;
  stats.kritz += logStats.ubertypes.kritzkrieg;
  stats.drops += logStats.drops;
  stats.heal_total += logStats.heal;
  
  if (stats.ave_time_to_build === 0) {
    stats.ave_time_to_build = logStats.medicstats.avg_time_to_build;
  } else {
    stats.ave_time_to_build = (stats.ave_time_to_build + logStats.medicstats.avg_time_to_build) / 2;
  }

  if (stats.ave_uber_length === 0) {
    stats.ave_uber_length = logStats.medicstats.avg_uber_length;
  } else {
    stats.ave_uber_length = (stats.ave_uber_length + logStats.medicstats.avg_uber_length) / 2;
  }

  if (stats.ave_time_before_healing === 0) {
    stats.ave_time_before_healing = logStats.medicstats.avg_time_before_healing;
  } else {
    stats.ave_time_before_healing = (stats.ave_time_before_healing + logStats.medicstats.avg_time_before_healing) / 2 ;
  }

  if (stats.ave_time_before_using === 0) {
    stats.ave_time_before_using = logStats.medicstats.avg_time_before_using;
  } else {
    stats.ave_time_before_using = (stats.ave_time_before_using + logStats.medicstats.avg_time_before_using) / 2;
  }

  return stats;
}

/**
 * Calculate pyro stats
 * Reflection kills are added when the pyro kills a projectile
 * in the weapon stats section
 * @param {StatsIndividual} stats current player stats
 * @param {Object} logStats the log stats
 */
const calculatePyroStats = (stats, logStats) => {
  // airblasts
  // calculated when they use a reflectable weapon to kill

  return stats;
}

// PERSISTANCE FUNCTIONS \\
/**
 * Returns the query from the output of the stats
 * @param {StatsAll} stats the stats for the player
 * @param {Boolean} real is the log for a match
 * @returns {Array} the query and parameters
 */
const addStatsAll = (player, stats, real) => {
  const now = getDateTime();
  return [stats.toQuery(real), stats.asArray().concat([now, player.id])];
}

/**
 * Returns the query from the output of the stats
 * @param {StatsIndividual} stats the stats for the player
 * @param {Boolean} real is the log for a match
 * @returns {Array} the query and parameters
 */
const addStatsIndividual = (player, stats, real) => {
  const now = getDateTime();
  return [stats[0].toQuery(real), stats[0].asArray().concat([now, player.id, stats[1]])];
}

/**
 * Get the players current stats
 * @param {Object} player the player object
 * @param {Boolean} real is the log for a match
 */
const getStatsAll = async (player, real) => {
  const res = await db.query(`SELECT * FROM stats_all_${real ? 'real' : 'total'} WHERE player_id=$1`, [player.id]);
  return res[0];
}

/**
 * Get the players current stats for specified class
 * @param {Object} player the player object
 * @param {String} className the class to get the stats from
 * @param {Boolean} real is the log for a match
 */
const getStatsIndividual = async (player, className, real) => {
  const res = await db.query(`SELECT * FROM stats_individual_${real ? 'real' : 'total'} WHERE player_id=$1 AND class=$2`, [player.id, className]);
  return res[0];
}

const getOrCreatePlayers = async (players) => {
  const client = await db.connect();

  try {
    const results = players.map(async player => {
      const res = await client.query('SELECT * FROM players WHERE steamid64=$1', [player.steamid64]);
      if(res.rows[0]) {
        return res.rows[0];
      } else {
        console.log(`Player ${player.steamid64} did not exist, creating...`);
        const now = getDateTime();
        const res = await client.query(`INSERT INTO players
                                  (steamid, steamid3, steamid64, alias, avatar, inserted_at, updated_at)
                                  VALUES ($1, $2, $3, $4, $5, $6, $7)
                                  RETURNING id, steamid, steamid3, steamid64, alias`,
          [player.steamid, player.steamid3, player.steamid64, player.alias, player.avatar, now, now]
        );
        return res.rows[0];
      }
    });
    return results;
  } catch(e) {
    throw new Error(e);
  } finally {
    client.release();
  }
}

/**
 * Returns the Steamid64 of the user
 * @param {String} steamid The steamid provided by the logs
 * @returns {String}
 */
const steamidToSteamid64 = (steamid) => {
  if(steamid.startsWith('[')) {
    parts = steamid.replace('[U:', '').replace(']', '').split(':');
    idPart1 = Number.parseInt(parts[0]);
    idPart2 = Number.parseInt(parts[1]);
    return (BigInt(idPart1) + BigInt(idPart2) + 76_561_197_960_265_727n).toString();
  } else {
    parts = steamid.replace('STEAM_0', '').split(':');
    idPart1 = Number.parseInt(parts[0]);
    idPart2 = Number.parseInt(parts[1]);
    return (BigInt(idPart1) + BigInt(idPart2) + 76_561_197_960_265_727n).toString;
  }
}

const steamid64ToSteamId3 = (steamid) => {
  steam_id2 = BigInt(steamid) - 76_561_197_960_265_728n;

  return `[U:1:${steam_id2}]`;
}

const steamid64ToSteamId = (steamid) => {
  steam_id1 = BigInt(steamid) % 2n;
  steam_id2 = BigInt(steamid) - 76_561_197_960_265_728n;

  steam_id2 = (steam_id2 - steam_id1) / 2n;

  return `STEAM_0:${steam_id1}:${steam_id2}` // 0 since tf2 is old
}

/**
 * Check to see if the player has stats
 * otherwise create them
 * @param {Object} player the player object
 * @param {Boolean} real is the log for a match
 */
const ensureStatsAllExist = async (player, real) => {
  const result = await getStatsAll(player, real);
  if (!result || result === {}) {
    const now = getDateTime();
    await db.query(`INSERT INTO stats_all_${real ? 'real' : 'total'} (player_id, inserted_at, updated_at) VALUES ($1, $2, $3)`, [player.id, now, now]);
  }
}

/**
 * Check to see if the player has stats
 * otherwise create them
 * @param {Object} player the player object
 * @param {String} className the class to get the stats from
 * @param {Boolean} real is the log for a match
 */
const ensureStatsIndividualExist = async (player, className, real) => {
  const result = await getStatsIndividual(player, className, real);
  if (!result || result === {}) {
    const now = getDateTime();
    await db.query(`INSERT INTO stats_individual_${real ? 'real' : 'total'} (class, player_id, inserted_at, updated_at) VALUES ($1, $2, $3, $4)`, [className, player.id, now, now]);
  }
}


// OTHER FUNCTIONS \\
/**
 * Get the current time
 * @returns {Date} current date
 */
const getDateTime = () => {
  return new Date();
}

const linkLogToPlayer = (player, log) => {
  const now = getDateTime();
  return ['INSERT INTO players_logs (player_id, log_id, inserted_at, updated_at) VALUES ($1, $2, $3, $4)', [player.id, log.id, now, now]];
}

const commitAllToDb = async () => {
  console.log('Starting transaction');
  const client = await db.connect();
  try {
    await client.query('BEGIN')
    queries.forEach(async query => {
      console.log('Running query');
      console.log(query[0]);
      console.log(query[1]);
      await client.query(query[0], query[1]);
    });
    await client.query('COMMIT');
    console.log('Transaction completed successfully');
  } catch(e) {
    console.error(e);
    console.error('Queries failed, rolling back changes');
    await client.query('ROLLBACK');
  } finally {
    client.release();
  }
}

const main = async () => {
  await db.connect().catch((error) => {
    throw new Error(error);
  });

  console.log("EVENT: \n" + JSON.stringify(event));

  const log = await fetch(`https://logs.tf/json/${event.log.logname}`).then((res) => res.json());

  const playerStubs = Object.keys(log.names).map(player => {
    const steamid64 = steamidToSteamid64(player)
    return {alias: log.names[player], steamid64, steamid3: steamid64ToSteamId3(steamid64), steamid: steamid64ToSteamId(steamid64), avatar: 'AVATAR'}
  });
  
  const players = await getOrCreatePlayers(playerStubs)

  players.forEach(player => {
    const steamid = log.names[player.steamid3] ? player.steamid3 : player.steamid;
    const real = !!event.match;

    const logData = log.players[steamid];

    individualStats = calculateStatsIndividual(player, steamid, logData, real);
    allStats = calculateStatsAll(player, steamid, logData, real);

    addStatsIndividual(player, individualStats, real).forEach((stat) => {
      queries.push(stat);
    });
    queries.push(addStatsAll(player, allStats, real));

    // also add total stats if real
    if (real) {
      individualStats = calculateStatsIndividual(player, steamid, logData, false);
      allStats = calculateStatsAll(player, steamid, logData, false);
      addStatsIndividual(player, individualStats, false).forEach((stat) => {
        queries.push(stat);
      });
      queries.push(addStatsAll(player, allStats, false));

      queries.push(linkLogToMatch(event.log, event.match));
    }

    queries.push(linkLogToPlayer(player, log));
  });

  await commitAllToDb();

  return logData;
};

module.exports = {
  addStatsAll,
  addStatsIndividual,

  getStatsAll,
  getStatsIndividual,

  getOrCreatePlayers,
  steamidToSteamid64,
  steamid64ToSteamId,
  steamid64ToSteamId3,

  ensureStatsAllExist,
  ensureStatsIndividualExist,

  linkLogToPlayer,

  commitAllToDb,

  calculateTotalStats,
  calculateSeenStats,
  calculateTimePlayedStats,

  calculateGenericStats,
  calculateWeaponStats,
  calculateMedicStats,
  calculatePyroStats,

  getDateTime,

  main,
};
