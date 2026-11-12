function errorHandler(error, _req, res, _next) {
  console.error(error);

  if (error.status && error.status >= 400 && error.status < 500) {
    return res.status(error.status).json({ message: error.message });
  }

  if (error.code === 11000) {
    const field = Object.keys(error.keyPattern || {})[0] || "field";
    return res.status(409).json({ message: `${field} already exists.` });
  }

  if (error.name === "ValidationError") {
    const messages = Object.values(error.errors).map((item) => item.message);
    return res.status(400).json({ message: messages.join(" ") });
  }

  if (error.name === "CastError") {
    return res.status(400).json({ message: "Invalid lecturer ID." });
  }

  if (error.name === "MulterError") {
    const message =
      error.code === "LIMIT_FILE_SIZE"
        ? `Image is too large. Maximum size is ${Number(process.env.MAX_IMAGE_SIZE_MB) || 5} MB.`
        : error.message;
    return res.status(400).json({ message });
  }

  if (error.message && error.message.startsWith("Only JPG")) {
    return res.status(400).json({ message: error.message });
  }

  return res
    .status(500)
    .json({ message: "An unexpected server error occurred." });
}

module.exports = errorHandler;
