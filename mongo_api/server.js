require("dotenv").config();

const app = require("./src/app");
const connectDatabase = require("./src/config/DatabaseConfig");
const createAdmin = require("./src/config/AdminConfig");

const PORT = Number(process.env.PORT) || 3000;

async function startServer() {
  try {
    await connectDatabase();
    await createAdmin();

    app.listen(PORT, "0.0.0.0", () => {
      console.log(`Mongo API is listening on http://0.0.0.0:${PORT}`);
      console.log(`Health check: http://127.0.0.1:${PORT}/api/health`);
    });
  } catch (error) {
    console.error("Mongo API startup failed:", error.message);
    process.exit(1);
  }
}

startServer();
