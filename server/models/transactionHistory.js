const mongoose = require("mongoose");

const transactionHistorySchema = mongoose.Schema({
  user_id: {
    type: String,
    required: true,
    trim: true,
  },
  transaction_datetime: {
    type: String,
  },
  amount: {
    type: Number,
  },
  // either "Deposit" / "Pay"
  transactionType: {
    type: String,
  }
});

// to convert a schema to a model
const TransactionHistory = mongoose.model("TransactionHistory", transactionHistorySchema);
module.exports = TransactionHistory;
