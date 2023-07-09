const mongoose = require("mongoose");

const paymentQRKeySchema = mongoose.Schema({
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
const PaymentQRKey = mongoose.model("PaymentQRKey", paymentQRKeySchema);
module.exports = PaymentQRKey;
