require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  connectionTimeoutMillis: 5000,
  idleTimeoutMillis: 30000,
  max: 10,
});

async function query(text, params = []) {
  return pool.query(text, params);
}

async function testConnection() {
  await query('SELECT 1');
}

module.exports = { pool, query, testConnection };