const mongoose = require("mongoose");
const GiangVien = require("../models/Lecturer");
const NguoiDung = require("../models/User");

async function connectDatabase() {
  const uri = process.env.MONGODB_URI;

  if (!uri) {
    throw new Error(
      "MONGODB_URI is missing. Please set it in the .env file or as an environment variable.",
    );
  }

  mongoose.set("strictQuery", true);
  await mongoose.connect(uri);

  // Wait for unique indexes so duplicate IDs/usernames are rejected from the first request.
  await Promise.all([GiangVien.init(), NguoiDung.init()]);
  console.log(`MongoDB connected: ${mongoose.connection.name}`);
}

module.exports = connectDatabase;
