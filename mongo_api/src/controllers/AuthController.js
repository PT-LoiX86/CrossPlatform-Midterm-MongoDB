const bcrypt = require("bcryptjs");
const User = require("../models/User");

async function login(req, res) {
  const username =
    typeof req.body.username === "string"
      ? req.body.username.trim().toLowerCase()
      : "";
  const password =
    typeof req.body.password === "string" ? req.body.password : "";

  if (!username || !password) {
    return res
      .status(400)
      .json({ message: "Username and password are required." });
  }

  const user = await User.findOne({ username }).select("+password");
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return res.status(401).json({ message: "Incorrect username or password." });
  }

  return res.json({
    message: "Login successful.",
    user: { username: user.username },
  });
}

module.exports = { login };
