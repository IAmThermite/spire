const { Pool } = require('pg');
const pool = new Pool();

const connect = async () => {
  console.log('connecting to postgres');
  try {
    await pool.connect()
  } catch(e) {
    throw new Error(e);
  }
};

const query = async (query) => {
  console.log('Running query...');
  console.log(query)
  try {
    const client = await pool.connect();
    const res = await client.query(query);
    client.release();

    return res.rows || [];
  } catch (e) {
    throw new Error(e);
  }
}

module.exports = {
  connect,
  query,
};