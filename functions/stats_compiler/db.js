const { Pool } = require('pg');
const pool = new Pool();

const connect = async () => {
  console.log('connecting to postgres');
  try {
    const client = await pool.connect();
    return client;
  } catch(e) {
    throw new Error(e);
  }
};

const query = async (query, params) => {
  const client = await pool.connect();
  try {
    const res = await client.query(query, params);

    return res.rows || [];
  } catch (e) {
    console.log(e)
    throw new Error(e);
  } finally {
    client.release();
  }
}

module.exports = {
  connect,
  query,
};