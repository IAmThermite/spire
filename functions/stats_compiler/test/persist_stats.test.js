const compiler = require('../index');
const db = require('../db');
const assert = require('assert');
const {StatsAll, StatsIndividual} = require('../stats');
const should = require('should');

let playerId = 0;

describe('getOrCreatePlayers', async () => {
  beforeEach(async () => {
    const now = compiler.getDateTime();
    await db.query('DELETE FROM players');
    await db.query('INSERT INTO players (steamid64, steamid3, steamid, alias, avatar, inserted_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id', ['1', '1', '1', 'ALIAS', 'AVATAR', now, now]);
  });

  afterEach(async () => {
    await db.query('DELETE FROM players');
  });

  it('should return the already existing player', async () => {
    const player_snubs = [{steamid: '1', steamid3: '1', steamid64: '1', alias: 'ALIAS', avatar: 'AVATAR'}];
    const players = await compiler.getOrCreatePlayers(player_snubs);
    players.forEach(player => {
      player.then(res => {
        assert.equal(res.alias, 'ALIAS');
      }).catch(error => {
        throw new Error(error)
      })
    });
  });

  it('should create and return a non existing player', async () => {
    const player_snubs = [{steamid: '1', steamid3: '1', steamid64: '1', alias: 'ALIAS', avatar: 'AVATAR'}, {steamid: '2', steamid3: '2', steamid64: '2', alias: 'ALIAS', avatar: 'AVATAR'}];
    const players = await compiler.getOrCreatePlayers(player_snubs);
    players.forEach(player => {
      player.then(res => {
        assert.equal(res.alias, 'ALIAS');
      }).catch(error => {
        throw new Error(error)
      })
    });
    assert.equal(players.length, 2);
  });
});

describe('test stats persistance', async () => {
  before(async () => {
    const now = compiler.getDateTime();
    const player = await db.query('INSERT INTO players (steamid64, steamid3, steamid, alias, avatar, inserted_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id', ['1', '1', '1', 'ALIAS', 'AVATAR', now, now]);
    playerId = player[0].id;
  });

  beforeEach(async () => {
    await deleteStats();
    await createStats();
  });

  after(async () => {
    await db.query('DELETE FROM players_logs');
    await db.query('DELETE FROM players');
    await deleteStats();
  });

  describe('addStatsAll', async () => {
    it('should update the stats', async () => {
      const stats = new StatsAll({
        total_kills: 10,
        total_deaths: 10,
        average_dpm: 230.5
      });

      const query = compiler.addStatsAll({id: playerId}, stats, false);
      await db.query(query[0], query[1]);

      const res = await getStatsAll(false);

      assert.equal(res.total_kills, 10);
      assert.equal(res.total_deaths, 10);
      assert.equal(res.average_dpm, 230.5);
    });
  });

  describe('addStatsIndividual', async () => {
    it('should update the stats', async () => {
      const stats = new StatsIndividual({
        kills: 10,
        deaths: 10,
        dpm: 230.5
      });

      const query = compiler.addStatsIndividual({id: playerId}, [stats, 'soldier'], false);
      await db.query(query[0], query[1]);
      const res = await getStatsIndividual(false, 'soldier');

      assert.equal(res.kills, 10);
      assert.equal(res.deaths, 10);
      assert.equal(res.dpm, 230.5);
    });
  });

  describe('getStatsAll', async () => {
    it('should return stats when they exist', async () => {
      const statsReal = await compiler.getStatsAll({id: playerId}, true);
      const statsTotal = await compiler.getStatsAll({id: playerId}, false);

      should(statsReal).not.be.undefined;
      should(statsReal).hasOwnProperty('total_kills');
      should(statsTotal).not.be.undefined;
      should(statsTotal).hasOwnProperty('total_kills');
    });
  });

  describe('getStatsIndividual', async () => {
    it('should return stats when they exist', async () => {
      const statsReal = await compiler.getStatsIndividual({id: playerId}, 'soldier', true);
      const statsTotal = await compiler.getStatsIndividual({id: playerId}, 'soldier', false);

      should(statsReal).not.be.undefined;
      should(statsReal).hasOwnProperty('kills');
      should(statsTotal).not.be.undefined;
      should(statsTotal).hasOwnProperty('kills');
    });

    it('should not return stats when they don\'t exist', async () => {
      const statsReal = await compiler.getStatsIndividual({id: playerId}, 'demoman', true);
      const statsTotal = await compiler.getStatsIndividual({id: playerId}, 'demoman', false);

      should(statsReal).be.undefined;
      should(statsTotal).be.undefined;
    });
  });

  describe('ensureStatsAllExist', async () => {
    it('should add stats when stats don\'t exist', async () => {
      await deleteStats();
      const stats = getStatsAll(false);
      should(stats).be.undefined;
      await compiler.ensureStatsAllExist({id: playerId}, false);
      const created = getStatsAll(false);
      should(created).be.not.undefined;
    });

    it('should not change stats when they alrady exist', async () => {
      await deleteStats();
      await createStats();
      await db.query('UPDATE stats_all_total SET total_kills=$1 WHERE player_id=$2', [10, playerId]);
      await compiler.ensureStatsAllExist({id: playerId}, false);
      const stats = await getStatsAll(false);
      should(stats).be.not.undefined;
      assert.equal(stats.total_kills, 10);
    });
  });

  describe('ensureStatsIndividualExist', async () => {
    it('should add stats when stats dont exist', async () => {
      await deleteStats();
      const stats = getStatsIndividual(false);
      should(stats).be.undefined;
      await compiler.ensureStatsIndividualExist({id: playerId}, 'soldier', false);
      const created = getStatsIndividual(false);
      should(created).be.not.undefined;
    });

    it('should not change stats when they alrady exist', async () => {
      await deleteStats();
      await createStats();
      await db.query('UPDATE stats_individual_total SET kills=$1 WHERE player_id=$2 AND class=$3', [10, playerId, 'soldier']);
      await compiler.ensureStatsIndividualExist({id: playerId}, 'soldier', false);
      const stats = await getStatsIndividual(false, 'soldier');
      should(stats).be.not.undefined;
      assert.equal(stats.kills, 10);
    });
  });

  describe('linkLogToPlayer', async () => {
    beforeEach(async () => {
      await db.query('DELETE FROM logs')
      await db.query('DELETE FROM players_logs');
    })

    it('should add the link', async () => {
      const now = compiler.getDateTime();
      const logId = await db.query('INSERT INTO logs (logfile, map, red_score, blue_score, red_kills, blue_kills, red_damage, blue_damage, length, date, inserted_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING id', [1, 'a_map', 1, 1, 1, 1, 1, 1, 1, now, now, now])
      const query = compiler.linkLogToPlayer({id: playerId}, {id: logId.id});
      await db.query(query[0], query[1]);
      const res = await db.query('SELECT * FROM players_logs');

      should(res[0]).not.be.undefined;
    });
  });
});

const getStatsAll = async (real) => {
  const res = await db.query(`SELECT * FROM stats_all_${real ? 'real': 'total'} WHERE player_id=$1`, [playerId]);
  return res[0];
}

const getStatsIndividual = async (real, className) => {
  const res = await db.query(`SELECT * FROM stats_individual_${real ? 'real': 'total'} WHERE player_id=$1 AND class=$2`, [playerId, className])
  return res[0];
}

const deleteStats = async () => {
  await db.query('DELETE FROM stats_individual_real');
  await db.query('DELETE FROM stats_individual_total');
  await db.query('DELETE FROM stats_all_real');
  await db.query('DELETE FROM stats_all_total');
}

const createStats = async () => {
  const now = compiler.getDateTime();
  const params = [playerId, now, now];
  await db.query('INSERT INTO stats_individual_real (class, player_id, inserted_at, updated_at) VALUES ($4, $1, $2, $3)', [...params, 'soldier']);
  await db.query('INSERT INTO stats_individual_total (class, player_id, inserted_at, updated_at) VALUES ($4, $1, $2, $3)', [...params, 'soldier']);
  await db.query('INSERT INTO stats_all_real (player_id, inserted_at, updated_at) VALUES ($1, $2, $3)', params);
  await db.query('INSERT INTO stats_all_total (player_id, inserted_at, updated_at) VALUES ($1, $2, $3)', params);
}
