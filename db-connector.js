const mysql = require('mysql2');
const pool = mysql.createPool({
  host: 'localhost',
  user: 'cs340_wheelken',
  password: '8078',
  database: 'cs340_wheelken',
  connectionLimit: 10
});

module.exports = pool;