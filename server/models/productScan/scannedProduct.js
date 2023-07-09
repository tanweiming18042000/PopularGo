const mongoose = require("mongoose");

const scannedProductSchema = mongoose.Schema({
  rfid_id: {
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
});

// to convert a schema to a model
const ScannedProduct = mongoose.model("ScannedProduct", scannedProductSchema);
module.exports = ScannedProduct;
