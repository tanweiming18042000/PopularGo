const express = require("express");
const ScannedProduct = require("../models/productScan/scannedProduct");

const productScanRouter = express.Router();
const Book = require("../models/book");

productScanRouter.get("/user", (req, res) => {
  res.json({ msg: "rivaan" });
});

// get request
// use the book_id to retrieve information from the Book table.
productScanRouter.get("/api/retrieveOneBook/:_id", async (req, res) => {
  try {
    const book = await Book.findOne({
      _id: req.params._id,
    }).exec();

    // get the item
    if (book) {
      res.json(book);
    } else {
      res.status(400).json({ msg: "Book with such id not found" });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// post request
// body = rfid_id, book
// if the rfid_id == rfid1 is not found, create one.
// if the rfid exist, check if the book.id is in the productList,
// if no, add one, and amend 1 to the end of quantity
// if yes, find the position of the bookId in the productList,
// then add 1 to that position in the quantityList,
// then add the price for the priceList (ori)
// --> finish all that, add the book.price to the subtotal,
// calculate the estimatedTax and total
productScanRouter.post("/api/createScannedProduct", async (req, res) => {
  try {
    const RFIDExist = await ScannedProduct.findOne({
      rfid_id: req.body.rfid_id,
    }).exec();

    // if the rfid_id == rfid1 is not found, create one.
    if (!RFIDExist) {
      const bookId = req.body.book_id;
      const bookPrice = req.body.book_price;

      const newScannedProduct = new ScannedProduct({
        rfid_id: req.body.rfid_id,
        bookIdList: [bookId],
        quantityList: [1],
        priceList: [bookPrice],
        subtotal: (bookPrice * 1).toFixed(2),
        estimatedTax: (bookPrice * 1 * 0.06).toFixed(2),
        total: (bookPrice * 1 + bookPrice * 1 * 0.06).toFixed(2),
      });

      await newScannedProduct.save();

      res.json(newScannedProduct);
    } else {
      // check if the book.id is in the bookIdList
      const bookId = req.body.book_id;
      const bookPrice = req.body.book_price;

      const scannedProduct = RFIDExist;

      const bookIndex = scannedProduct.bookIdList.indexOf(bookId);

      // does not exist
      if (bookIndex === -1) {
        scannedProduct.bookIdList.push(bookId);
        scannedProduct.quantityList.push(1);
        scannedProduct.priceList.push(bookPrice);
      } else {
        scannedProduct.quantityList[bookIndex] += 1;
      }

      const subtotal = scannedProduct.priceList.reduce(
        (acc, price, index) => acc + price * scannedProduct.quantityList[index],
        0
      );
    //   subtotal = subtotal.toFixed(2);
      const estimatedTax = +(subtotal * 0.06).toFixed(2);
      const total = +(subtotal + estimatedTax).toFixed(2);

      // Update the fields in the scannedProduct
      scannedProduct.subtotal = subtotal;
      scannedProduct.estimatedTax = estimatedTax;
      scannedProduct.total = total;

      await scannedProduct.save();

      res.json(scannedProduct);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = productScanRouter;
