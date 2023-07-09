const mongoose = require("mongoose");

const wishlistSchema = mongoose.Schema({
  user_id: {
    type: String,
    required: true,
    trim: true,
  },
  book_id: {
    required: true,
    type: String,
    trim: true,
  },
  quantity: {
    type: Number,
  },
  price: {
    type: Number,
  }
});

// to convert a schema to a model
const Wishlist = mongoose.model("Wishlist", wishlistSchema);
module.exports = Wishlist;
