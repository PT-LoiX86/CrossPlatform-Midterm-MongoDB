const mongoose = require("mongoose");

const lecturerSchema = new mongoose.Schema(
  {
    IDGV: {
      type: String,
      required: [true, "Lecturer ID is required."],
      unique: true,
      trim: true,
    },
    Fullname: {
      type: String,
      required: [true, "Lecturer fullname is required."],
      trim: true,
    },
    Image: {
      type: String,
      required: [true, "Lecturer portrait is required."],
    },
    SumClass: {
      type: Number,
      required: [true, "Total classes is required."],
      min: [1, "Total classes must be a positive integer."],
      validate: {
        validator: Number.isInteger,
        message: "Total classes must be an integer.",
      },
    },
  },
  {
    timestamps: true,
    collection: "GiangVien",
  },
);

module.exports = mongoose.model("Lecturer", lecturerSchema, "GiangVien");
