const bcrypt = require("bcryptjs");
const NguoiDung = require("../models/User");

async function createAdmin() {
  const username = process.env.ADMIN_USERNAME || "admin";
  const password = process.env.ADMIN_PASSWORD || "123456";

  if (!username || !password) {
    throw new Error("ADMIN_USERNAME and ADMIN_PASSWORD must not be empty.");
  }

  const existingAdmin = await NguoiDung.findOne({ username });

  if (existingAdmin) {
    console.log(
      `Admin account already exists: ${username} (password was not reset).`,
    );
    return;
  }

  const passwordHash = await bcrypt.hash(password, 12);
  await NguoiDung.create({ username, password: passwordHash });
  console.log(`Initial admin account created: ${username}`);
}

module.exports = createAdmin;
