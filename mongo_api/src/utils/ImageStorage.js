const fs = require("node:fs/promises");
const path = require("node:path");
const crypto = require("node:crypto");
const multer = require("multer");

// Storage directory
const uploadsDirectory = path.resolve(__dirname, "../../uploads");

// Allowed image formats
const extensionByMimeType = {
  "image/jpeg": ".jpg",
  "image/jpg": ".jpg",
  "image/pjpeg": ".jpg",
  "image/png": ".png",
  "image/webp": ".webp",
};

const allowedMimeTypes = new Set(Object.keys(extensionByMimeType));

// Maximum image size (default: 5 MB)
const configuredMaxSize = Number(process.env.MAX_IMAGE_SIZE_MB || 5);

const maxImageSizeMb =
  Number.isFinite(configuredMaxSize) && configuredMaxSize > 0
    ? configuredMaxSize
    : 5;

const storage = multer.diskStorage({
  destination: uploadsDirectory,

  filename: (_req, file, callback) => {
    const extension = extensionByMimeType[file.mimetype];

    if (!extension) {
      return callback(new Error("Unsupported image format."));
    }

    callback(null, `${crypto.randomUUID()}${extension}`);
  },
});

const upload = multer({
  storage,

  limits: {
    fileSize: Math.floor(maxImageSizeMb * 1024 * 1024),
    files: 1,
  },

  fileFilter: (_req, file, callback) => {
    console.log("Uploaded filename:", file.originalname);
    console.log("Received MIME type:", file.mimetype);

    if (!allowedMimeTypes.has(file.mimetype)) {
      return callback(
        new Error("Only JPG, PNG, and WEBP images are supported."),
      );
    }

    callback(null, true);
  },
});

async function removeStoredImage(imageUrl) {
  if (typeof imageUrl !== "string" || !imageUrl.startsWith("/uploads/")) {
    return;
  }

  const filename = imageUrl.slice("/uploads/".length);

  if (
    !filename ||
    filename !== path.basename(filename) ||
    filename === "." ||
    filename === ".."
  ) {
    return;
  }

  const imagePath = path.join(uploadsDirectory, filename);

  try {
    await fs.unlink(imagePath);
  } catch (error) {
    if (error.code !== "ENOENT") {
      console.warn(`Could not remove image ${filename}:`, error.message);
    }
  }
}

module.exports = {
  upload,
  uploadsDirectory,
  removeStoredImage,
};
