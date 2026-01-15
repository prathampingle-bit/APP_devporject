const mysql = require('mysql2/promise');
require('dotenv').config();

// Supports either a single DATABASE_URL or discrete DB_* vars for managed MySQL (RDS, PlanetScale, Neon, etc.)
// Example URL: mysql://user:pass@host:3306/dbname
const useUrl = !!process.env.DATABASE_URL;

const pool = mysql.createPool(
  useUrl
    ? {
        uri: process.env.DATABASE_URL,
        waitForConnections: true,
        connectionLimit: 10,
        ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
      }
    : {
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'app_db',
        port: Number(process.env.DB_PORT || 3306),
        waitForConnections: true,
        connectionLimit: 10,
        ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
      }
);

module.exports = pool;
