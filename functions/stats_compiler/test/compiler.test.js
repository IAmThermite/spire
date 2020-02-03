const compiler = require('../index');
const assert = require('assert');
const {StatsAll, StatsIndividual} = require('../stats');

const logData = {
  class_stats: [
    {
      type: 'soldier',
      kills: 10,
      assists: 10,
      deaths: 10,
      dmg: 10000,
      weapon: {
        tf_projectile_rocket: {
          kills: 21,
          dmg: 10000,
          avg_dmg: 55.5,
          shots: 100,
          hits: 50
        },
        shotgun_soldier: {
          kills: 5,
          dmg: 5000,
          avg_dmg: 55.5,
          shots: 50,
          hits: 20
        }
      },
      total_time: 1000
    },
    {
      type: 'demoman',
      kills: 10,
      assists: 10,
      deaths: 10,
      dmg: 10000,
      weapon: {
        tf_projectile_pipe: {
          kills: 21,
          dmg: 10000,
          avg_dmg: 55.5,
          shots: 100,
          hits: 50
        },
        tf_projectile_pipe_remote: {
          kills: 5,
          dmg: 5000,
          avg_dmg: 55.5,
          shots: 50,
          hits: 20
        },
      },
      total_time: 1000
    }
  ],
  kills: 10,
  deaths: 10,
  assists: 10,
  suicides: 0,
  dmg: 10000,
  lks: 5, // longest kill streak
  as: 5, // airshots
  dapm: 260, // dpm
  ubers: 10,
  ubertypes: {
    medigun: 5,
    kritzkrieg: 5
  },
  drops: 1,
  backstabs: 10,
  headshots: 10,
  headshots_hit: 10,
  heal: 10000, // healing done
  cpc: 5, // control points captured
  medicstats: {
    deaths_with_95_99_uber: 1,
    advantages_lost: 1,
    biggest_advantage_lost: 20,
    deaths_within_20s_after_uber: 3,
    avg_time_before_healing: 1.95,
    avg_time_to_build: 58.45,
    avg_time_before_using: 15.42,
    avg_uber_length: 7.1
  }
}

describe('calculateAllStats', () => {
  describe('calculateTotalStats', () => {
    it('should add total stats when there are no previous stats', () => {
      const stats = new StatsAll({});
  
      compiler.calculateTotalStats(stats, logData);
  
      assert.equal(stats.total_kills, 10);
      assert.equal(stats.total_deaths, 10);
      assert.equal(stats.total_assists, 10);
      assert.equal(stats.total_damage, 10000);
      assert.equal(stats.total_healing, 10000);
      assert.equal(stats.total_captures, 5);
  
      assert.equal(stats.longest_killstreak, 5);
      
      assert.equal(stats.average_dpm, 260);
    });

    it('should add stats to existing stats', () => {
      const stats = new StatsAll({
        total_kills: 2,
        total_deaths: 2,
        total_assists: 2,
        total_damage: 5000,
        total_healing: 5000,
        total_captures: 2,
        longest_killstreak: 2,
        average_dpm: 100
      });
  
      compiler.calculateTotalStats(stats, logData);
  
      assert.equal(stats.total_kills, 12);
      assert.equal(stats.total_deaths, 12);
      assert.equal(stats.total_assists, 12);
      assert.equal(stats.total_damage, 15000);
      assert.equal(stats.total_healing, 15000);
      assert.equal(stats.total_captures, 7);
  
      assert.equal(stats.longest_killstreak, 5);
      
      assert.equal(stats.average_dpm, 180);
    });
  });
  
  describe('calculateSeenStats', () => {
    it('should add one to each class played', () => {
      const stats = new StatsAll({times_seen_soldier: 1, times_seen_demoman: 1});
  
      compiler.calculateSeenStats(stats, logData);
  
      assert.equal(stats.times_seen_soldier, 2);
      assert.equal(stats.times_seen_demoman, 2);
    });
  });
  
  describe('calculateTimePlayedStats', () => {
    it('should increase the time played', () => {
      const stats = new StatsAll({});
  
      compiler.calculateTimePlayedStats(stats, logData);
  
      assert.equal(stats.time_played, 2000);
    })
  });
});

describe('calculateStatsIndividual', () => {
  describe('calculateGenericStats', () => {
    it('should add to the stats', () => {
      const stats = new StatsIndividual({});
      compiler.calculateGenericStats(stats, logData.class_stats[0]);
      
      assert.equal(stats.kills, 10);
      assert.equal(stats.deaths, 10);
      assert.equal(stats.assists, 10);
      assert.equal(stats.dpm, 600);
      assert.equal(stats.dmg_total, 10000);

      assert.equal(stats.total_playtime, 1000);
      assert.equal(stats.number_of_logs, 1);
    });

    it('should add to stats when stats are already present', () => {
      const stats = new StatsIndividual({
        kills: 2,
        deaths: 2,
        assists: 2,
        dpm: 300,
        dmg_total: 2000,
        total_playtime: 500,
        number_of_logs: 1,
      });
      compiler.calculateGenericStats(stats, logData.class_stats[0]);
      
      assert.equal(stats.kills, 12);
      assert.equal(stats.deaths, 12);
      assert.equal(stats.assists, 12);
      assert.equal(stats.dpm, 450);
      assert.equal(stats.dmg_total, 12000);

      assert.equal(stats.total_playtime, 1500);
      assert.equal(stats.number_of_logs, 2);
    })
  });

  describe('calculateWeaponStats', () => {
    it('should add shots hit stats', () => {
      logData.class_stats.forEach((classStats) => {
        const stats = new StatsIndividual({});
        compiler.calculateWeaponStats(stats, classStats);
  
        assert.equal(stats.kills_pri, 21);
        assert.equal(stats.shots_fired_pri, 100);
        assert.equal(stats.shots_hit_pri, 50);
        assert.equal(stats.dmg_per_shot_pri, 55.5);
        assert.equal(stats.accuracy_pri, 50);

        assert.equal(stats.kills_sec, 5);
        assert.equal(stats.shots_fired_sec, 50);
        assert.equal(stats.shots_hit_sec, 20);
        assert.equal(stats.dmg_per_shot_sec, 55.5);
        assert.equal(stats.accuracy_sec, 40);
      });
    });
  });

  describe('calculateMedicStats', () => {
    it('should add to stats', () => {
      const stats = new StatsIndividual({});
      compiler.calculateMedicStats(stats, logData);

      assert.equal(stats.ubers, 5);
      assert.equal(stats.kritz, 5);
      assert.equal(stats.drops, 1);
      assert.equal(stats.heal_total, 10000);

      assert.equal(stats.ave_time_to_build, 58.45);
      assert.equal(stats.ave_uber_length, 7.1);
      assert.equal(stats.ave_time_before_healing, 1.95);
      assert.equal(stats.ave_time_before_using, 15.42);
    });

    it('should add to stats when there are existing stats', () => {
      const stats = new StatsIndividual({
        ubers: 2,
        kritz: 2,
        drops: 2,
        heal_total: 2000,

        ave_time_to_build: 50.3,
        ave_uber_length: 5.2,
        ave_time_before_healing: 5.2,
        ave_time_before_using: 5.2
      });
      compiler.calculateMedicStats(stats, logData);

      assert.equal(stats.ubers, 7);
      assert.equal(stats.kritz, 7);
      assert.equal(stats.drops, 3);
      assert.equal(stats.heal_total, 12000);

      assert.equal(stats.ave_time_to_build, 54.375);
      assert.equal(stats.ave_uber_length, 6.15);
      assert.equal(stats.ave_time_before_healing, 3.575);
      assert.equal(stats.ave_time_before_using, 10.31);
    });
  });

  describe('calculatePyroStats', () => {

  });
});
