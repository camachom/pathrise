var express = require("express");
var router = express.Router();
const db = require("../db.js");

/* GET home page. */
router.get("/", async (req, res, next) => {
	try {
		const users = await db.any("SELECT * FROM jobs LIMIT 50");
		console.log(users);
	} catch (e) {
		console.log(e);
	}
});

module.exports = router;
