const pgp = require("pg-promise")();
const db = pgp({
	host: "db",
	user: "postgres",
	database: "pathrise",
	password: "example",
	port: 5432,
});

module.exports = db;
