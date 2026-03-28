import knex from 'knex';

const db = knex({
  client: 'mysql2',
  connection: {
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '0909206693Thienhoangpd@#',
    database: 'librarymanagement'
  },
  pool: { min: 0, max: 10 }
});

export default db;