const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

const DB_URL = process.env.DB_URL;

if (!DB_URL) {
  console.warn('Warning: DB_URL is not set in environment');
}

async function getConnection() {
  return mysql.createConnection(DB_URL);
}

module.exports = { getConnection };
