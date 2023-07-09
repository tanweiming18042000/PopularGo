const mongoose = require("mongoose");

const qrKeySchema = mongoose.Schema({
  user_id: {
    type: String,
    required: true,
    trim: true,
  },
  qrStr: {
    type: String,
  }
});

// to convert a schema to a model
const QRKey = mongoose.model("QRKey", qrKeySchema);
module.exports = QRKey;
