const express = require("express");
const cors = require("cors");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");

const boardsRouter = require("./routes/boards");

const app = express();

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));
app.use(cors());

app.use("/boards", boardsRouter);

app.use((error, req, res, next) => {
	if (!error.statusCode) error.statusCode = 500;

	return res.status(error.statusCode).json({ error: error.toString() });
});

module.exports = app;
