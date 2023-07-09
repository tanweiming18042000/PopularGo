const mongoose = require("mongoose");

const discountSchema = mongoose.Schema({
  img: {
    type: String,
  },
  title: {
    type: String,
  },
  subtitle: {
    type: String,
  },
  genre: { 
    type: [String], 
  },
  maxPrice: {
    type: Number,
  },
  mustOverMaxPrice: {
    type: String,
  },
  discountPercent: {
    type: Number,
  },

});

// to convert a schema to a model
const Discount = mongoose.model("Discount", discountSchema);
module.exports = Discount;
