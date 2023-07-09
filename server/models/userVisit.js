const mongoose = require("mongoose");

const userVisitSchema = mongoose.Schema({
  user_id: {
    type: String,
    required: true,
    trim: true,
  },
  start_datetime: {
    type: String,
  },
  end_datetime: {
    type: String,
  },
  // make it to seconds
  duration: {
    type: Number,
  }
});

// to convert a schema to a model
const UserVisit = mongoose.model("UserVisit", userVisitSchema);
module.exports = UserVisit;
