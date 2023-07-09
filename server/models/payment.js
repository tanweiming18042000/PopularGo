const mongoose = require("mongoose");

const paymentSchema = mongoose.Schema({
  userVisit_id: {
    type: String,
  },
  bookIdList: {
    type: [String],
    trim: true,
  },
  quantityList: {
    type: [Number],
  },
  priceList: { 
    type: [Number],  
  },
  subtotal: {
    type: Number,
  },
  estimatedTax: {
    type: Number,
  },
  total: {
    type: Number,
  },
  status: {
    type: String,
  }
});

// to convert a schema to a model
const Payment = mongoose.model("Payment", paymentSchema);
module.exports = Payment;
