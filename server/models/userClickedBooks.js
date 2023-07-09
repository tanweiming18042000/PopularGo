const mongoose = require("mongoose");

const userClickedBooksSchema = mongoose.Schema({
  user_id: {
    type: String,
  },
  genreList: {
    type: [
      [String], // Updated to a nested array of strings
    ],
  },
  clicked_datetime: {
    type: [String],
  },
});

// to convert a schema to a model
const UserClickedBooks = mongoose.model(
  "UserClickedBooks",
  userClickedBooksSchema
);
module.exports = UserClickedBooks;
