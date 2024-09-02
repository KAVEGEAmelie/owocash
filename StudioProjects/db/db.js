const mysql = require('mysql2/promise');
require('dotenv').config();

// Créer un pool de connexions
const connection = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

// Tester la connexion
connection.getConnection()
  .then(conn => {
    console.log('Connecté à la base de données MySQL.');
    conn.release(); // Libérer la connexion après le test
  })
  .catch(err => {
    console.error('Erreur de connexion à la base de données: ', err);
  });

module.exports = connection;
