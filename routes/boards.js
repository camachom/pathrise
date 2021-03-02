const express = require("express");
const router = express.Router();
const db = require("../db.js");
const { param, validationResult } = require("express-validator");

router.get("/", async (req, res, next) => {
	try {
		const boards = await db.any("SELECT * FROM boards;");
		res.json(boards);
	} catch (e) {
		next(e);
	}
});

router.get(
	"/:id/jobs",
	param("id").isInt().not().isEmpty(),
	async (req, res, next) => {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			next(errors[0]);
			return;
		}

		const { offset = 0, limit = 20 } = req.query;
		const { id } = req.params;

		const getTotalJobs = async () => {
			return await db.one("SELECT COUNT(*) FROM jobs WHERE board_id = $1;", [
				id,
			]);
		};

		const getJobs = async () => {
			return await db.any(
				"SELECT * FROM jobs WHERE board_id = $1 LIMIT $2 OFFSET $3;",
				[id, limit, offset]
			);
		};

		const getBoard = async () => {
			return await db.one("SELECT * FROM boards WHERE id = $1;", [id]);
		};

		try {
			const [jobs, board, { count }] = await Promise.all([
				getJobs(),
				getBoard(),
				getTotalJobs(),
			]);

			res.json({
				jobs,
				board,
				paging: {
					total: count,
					page: Math.floor(offset / limit),
					pages: Math.floor(count / limit),
				},
			});
		} catch (e) {
			next(e);
		}
	}
);

module.exports = router;
