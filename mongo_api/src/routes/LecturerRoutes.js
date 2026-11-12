const express = require("express");
const controller = require("../controllers/LecturerController");
const upload = require("../utils/ImageStorage").upload;

const router = express.Router();

router.get("/", controller.getAllLecturers);
router.get("/:id", controller.getLecturerById);
router.post("/", upload.single("image"), controller.addLecturer);
router.put("/:id", upload.single("image"), controller.updateLecturer);
router.delete("/:id", controller.removeLecturer);

module.exports = router;
