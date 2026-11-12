const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const path = require("node:path");
const AuthRoutes = require("./routes/AuthRoutes");
const LecturerRoutes = require("./routes/LecturerRoutes");
const errorHandler = require("./utils/ErrorHandler");
const { uploadsDirectory } = require("./utils/ImageStorage");

const app = express();

app.use(cors());
app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static(uploadsDirectory));

app.get("/api/health", (_req, res) => {
  res.json({
    api: "ok",
    database:
      mongoose.connection.readyState === 1 ? "connected" : "disconnected",
  });
});

app.use("/api/auth", AuthRoutes);
app.use("/api/giang-vien", LecturerRoutes);

app.use((_req, res) => {
  res.status(404).json({ message: "API endpoint not found." });
});

app.use(errorHandler);

module.exports = app;
