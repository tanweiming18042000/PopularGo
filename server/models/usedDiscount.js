const mongoose = require("mongoose");

const usedDiscountSchema = mongoose.Schema({
  user_id: {
    type: String,
  },
  discount_id: {
    type: String,
  },
});

// to convert a schema to a model
const UsedDiscount = mongoose.model("UsedDiscount", usedDiscountSchema);
module.exports = UsedDiscount;
