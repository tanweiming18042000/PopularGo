const mongoose = require("mongoose");

const bookSchema = mongoose.Schema({
  img: {
    type: String,
  },
  title: {
    required: true,
    type: String,
    trim: true,
  },
  authName: {
    required: true,
    type: String,
    trim: true,
  },
  genre: { 
    type: [String], 
    required: true 
  },
  price: {
    required: true,
    type: Number,
  },
  pageNum: {
    required: true,
    type: Number,
  },
  description: {
    required: true,
    type: String,
    trim: true,
  },
});

// to convert a schema to a model
const Book = mongoose.model("Book", bookSchema);
module.exports = Book;
