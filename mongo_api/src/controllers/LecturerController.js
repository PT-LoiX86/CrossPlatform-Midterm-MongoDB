const Lecturer = require("../models/Lecturer");
const { removeStoredImage } = require("../utils/ImageStorage");

function validateLecturerFields(body) {
  const IDGV = typeof body.IDGV === "string" ? body.IDGV.trim() : "";
  const Fullname =
    typeof body.Fullname === "string" ? body.Fullname.trim() : "";
  const rawSumClass = body.SumClass;
  const SumClass =
    rawSumClass === "" || rawSumClass === undefined ? NaN : Number(rawSumClass);

  if (!IDGV)
    throw Object.assign(new Error("Lecturer ID is required."), { status: 400 });
  if (!Fullname)
    throw Object.assign(new Error("Lecturer fullname is required."), {
      status: 400,
    });
  if (!Number.isInteger(SumClass) || SumClass <= 0) {
    throw Object.assign(
      new Error("Total classes must be a positive integer."),
      { status: 400 },
    );
  }

  return { IDGV, Fullname, SumClass };
}

async function getAllLecturers(req, res) {
  const lecturers = await Lecturer.find().sort({ Fullname: 1 });
  res.json(lecturers);
}

async function getLecturerById(req, res) {
  const lecturer = await Lecturer.findById(req.params.id);
  if (!lecturer)
    return res.status(404).json({ message: "Lecturer not found." });
  res.json(lecturer);
}

async function addLecturer(req, res, next) {
  const savedImageUrl = req.file ? `/uploads/${req.file.filename}` : null;
  try {
    const fields = validateLecturerFields(req.body);
    if (!savedImageUrl) {
      throw Object.assign(new Error("Lecturer portrait is required."), {
        status: 400,
      });
    }

    const lecturer = await Lecturer.create({
      ...fields,
      Image: savedImageUrl,
    });

    return res.status(201).json(lecturer);
  } catch (error) {
    if (savedImageUrl) await removeStoredImage(savedImageUrl);
    return next(error);
  }
}

async function updateLecturer(req, res, next) {
  const newImageUrl = req.file ? `/uploads/${req.file.filename}` : null;
  try {
    const lecturer = await Lecturer.findById(req.params.id);
    if (!lecturer) {
      if (newImageUrl) await removeStoredImage(newImageUrl);
      return res.status(404).json({ message: "Lecturer not found." });
    }

    const fields = validateLecturerFields(req.body);
    const previousImageUrl = lecturer.Image;

    if (newImageUrl) {
      lecturer.Image = newImageUrl;
    }

    lecturer.IDGV = fields.IDGV;
    lecturer.Fullname = fields.Fullname;
    lecturer.SumClass = fields.SumClass;
    await lecturer.save();

    if (newImageUrl && previousImageUrl) {
      await removeStoredImage(previousImageUrl);
    }

    return res.json(lecturer);
  } catch (error) {
    if (newImageUrl) await removeStoredImage(newImageUrl);
    return next(error);
  }
}

async function removeLecturer(req, res, next) {
  try {
    const lecturer = await Lecturer.findByIdAndDelete(req.params.id);
    if (!lecturer)
      return res.status(404).json({ message: "Lecturer not found." });

    if (lecturer.Image) await removeStoredImage(lecturer.Image);
    return res.json({ message: "Lecturer deleted successfully." });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  getAllLecturers,
  getLecturerById,
  addLecturer,
  updateLecturer,
  removeLecturer,
};
