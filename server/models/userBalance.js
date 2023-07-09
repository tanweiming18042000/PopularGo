const mongoose = require("mongoose");

const userBalanceSchema = mongoose.Schema({
  user_id: {
    type: String,
    required: true,
    trim: true,
  },
  totalBalance: {
    type: Number,
  },
});

// to convert a schema to a model
const UserBalance = mongoose.model("UserBalance", userBalanceSchema);
module.exports = UserBalance;
