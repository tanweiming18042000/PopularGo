const express = require("express");
const User = require("../models/user");
const Book = require("../models/book");
const Wishlist = require("../models/wishlist");
const UserVisit = require("../models/userVisit");
const Payment = require("../models/payment");
const UserBalance = require("../models/userBalance");
const PaymentQRKey = require("../models/paymentQRKey");
const TransactionHistory = require("../models/transactionHistory");
const Discount = require("../models/discount");
const UsedDiscount = require("../models/usedDiscount");
const ScannedProduct = require("../models/productScan/scannedProduct");

const exitRouter = express.Router();

// scan the customer qr code to get the userId for userVisit
// if no, produce error sound, if yes, proceed
exitRouter.get("/api/getPayUserId/:qrStr", async (req, res) => {
    try {
      const qrKeyItem = await PaymentQRKey.findOne({
        qrStr: req.params.qrStr,
      }).exec();
  
      // get the item
      if (qrKeyItem) {
        console.log('hello1');
        // get the userid
        const userId = qrKeyItem.user_id;
        res.json({ user_id: userId });
      } else {
        console.log('hello2');
        res.status(400).json({ msg: "QRKey not found" });
      }
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
  
  // get request
  // parameter = RFID_ID
  // get the bookListID
  exitRouter.get("/api/getScannedBookIdList/:rfid_id", async (req, res) => {
    try {
      const scannedProduct = await ScannedProduct.findOne({
        rfid_id: req.params.rfid_id,
      }).exec();
  
      // Check if a scanned product was found
      if (scannedProduct) {
        // Return only the bookIdList property
        res.json(scannedProduct.bookIdList);
      } else {
        res
          .status(400)
          .json({ msg: "Scanned product with such RFID ID not found" });
      }
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
  
  // get request
  // parameter = bookListID
  // get the genre list from the book table, with no repetitive
  exitRouter.get("/api/getScannedBookGenreList/:bookIdList", async (req, res) => {
    try {
      const bookIdList = req.params.bookIdList.split(",");
  
      const books = await Book.find({
        _id: { $in: bookIdList },
      }).exec();
  
      if (books.length > 0) {
        // Combine the genre arrays for all the books
        const combinedGenres = books.reduce((result, book) => {
          return [...result, ...book.genre];
        }, []);
  
        // Remove duplicate genres
        const uniqueGenres = [...new Set(combinedGenres)];
  
        res.json(uniqueGenres);
      } else {
        res.status(400).json({ msg: "No books found for the provided IDs" });
      }
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
  
  // get request
  // parameter = genreList
  // check from the discount table whether got the genre or not.
  // then return the discountIdList
  exitRouter.get("/api/getDiscountIdList/:genreList", async (req, res) => {
      try {
        const genreList = req.params.genreList.split(",");
    
        const discounts = await Discount.find({
          genre: { $in: genreList }
        }).exec();
    
        if (discounts.length > 0) {
          const discountIdList = discounts.map(discount => discount._id);
          res.json(discountIdList);
        } else {
          res.status(400).json({ msg: "No discounts found for the provided genres" });
        }
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });
  
  // get request
  // parameter = userId, discountIdList
  // check from the usedDiscount table and return unusedDiscountIDList based on userId
  exitRouter.get("/api/getUnusedDiscountIdList/:user_id/:discountIdList", async (req, res) => {
      try {
        const user_id = req.params.user_id;
        const discountIdList = req.params.discountIdList.split(",");
    
        const usedDiscounts = await UsedDiscount.find({
          user_id: user_id,
          discount_id: { $in: discountIdList }
        }).exec();
    
        const usedDiscountIds = usedDiscounts.map(usedDiscount => usedDiscount.discount_id);
    
        const unusedDiscountIds = discountIdList.filter(discountId => !usedDiscountIds.includes(discountId));
    
        res.json(unusedDiscountIds);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

module.exports = exitRouter;
