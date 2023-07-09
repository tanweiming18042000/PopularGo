const express = require("express");
const User = require("../models/user");
const bcryptjs = require("bcryptjs");
const jwt = require("jsonwebtoken");
const sendMail = require("../email");
const authMid = require("../middleware/auth_mid");
const multer = require("multer");
const Book = require("../models/book");
const fs = require("fs");
const Wishlist = require("../models/wishlist");
const UserVisit = require("../models/userVisit");
const QRKey = require("../models/qrKey");
const Payment = require("../models/payment");
const UserBalance = require("../models/userBalance");
const PaymentQRKey = require("../models/paymentQRKey");
const TransactionHistory = require("../models/transactionHistory");
const Discount = require("../models/discount");
const UsedDiscount = require("../models/usedDiscount");
const ScannedProduct = require("../models/productScan/scannedProduct");
const UserClickedBook = require("../models/userClickedBooks");
const moment = require('moment');
const lodash = require('lodash');

const authRouter = express.Router();
const app = express();
// setting options for multer
// image storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = "./uploads";
    fs.mkdirSync(uploadDir, { recursive: true }); // Create directory recursively if it doesn't exist
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  },
});

// const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// sign up route
authRouter.post("/api/signup", async (req, res) => {
  try {
    // get data from client
    const { name, email, password } = req.body;

    // check whether same email exist
    const userExist = await User.findOne({ email });

    if (userExist) {
      return res
        .status(400)
        .json({ msg: "User with same email already exists!" });
    }

    // check if the password is too short < 6 letters
    if (password.length < 6) {
      return res
        .status(400)
        .json({ msg: "Password cannot be shorter than 6 letters!" });
    }

    // encrypt the password
    const hashPassword = await bcryptjs.hash(password, 8);

    // create an User object to be stored
    let user = new User({
      name,
      email,
      password: hashPassword,
    });

    // post that data in database
    user = await user.save();

    // send User to client
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// sign in route
authRouter.post("/api/signin", async (req, res) => {
  try {
    const { email, password } = req.body;

    // validate email
    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exist!" });
    }

    // validate password (using user object that is got from findOne email)
    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Password not matching!" });
    }

    // get the token for the User so that can be used in every page
    const token = jwt.sign({ id: user._id }, "passwordKey");
    res.json({ token, ...user._doc });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get verified user
authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("userToken");
    if (!token) return res.json(false);
    const verified = jwt.verify(token, "passwordKey");
    if (!verified) return res.json(false);

    const user = await User.findById(verified.id);
    if (!user) return res.json(false);
    res.json(true);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get user data
authRouter.get("/", authMid, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.token });
});

// reset pwd email route
authRouter.post("/api/resetPwdEmail", async (req, res) => {
  try {
    // get data from client
    const { email, otpCode } = req.body;

    // check whether same email exist
    const userExist = await User.findOne({ email });

    if (!userExist) {
      console.log("email not exist");
      return res
        .status(400)
        .json({ msg: "User with this email does not exist!" });
    }

    console.log("This is email: " + email);
    console.log("This is type of email: " + typeof email);
    // send OPT code to user email
    // 1. generate a random 4 digit number
    //const otpCode = Math.floor(Math.random() * 9000 + 1000);

    console.log("This is otpCode: " + otpCode);
    console.log("This is type of otpCode: " + typeof otpCode);
    // 2. send email (OPT code to user for verification)
    sendMail.sendMail(email, otpCode);
    console.log("Really sent email");

    res.json(userExist);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// OTP page validate OTP code
// if same, pass, else, send error message
authRouter.post("/api/resetValidOTP", async (req, res) => {
  try {
    // get data from client
    const { otpCode, pin1, pin2, pin3, pin4 } = req.body;

    // compare the otp
    const userOTP =
      parseInt(pin1) * 1000 +
      parseInt(pin2) * 100 +
      parseInt(pin3) * 10 +
      parseInt(pin4);

    if (userOTP != otpCode) {
      console.log("Incorrect OTP");
      return res.status(400).json({ msg: "Wrong OTP entered!" });
    }

    res.json(userOTP);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// use email to find from user and update the password with hash
authRouter.post("/api/resetUserPwd", async (req, res) => {
  try {
    const hashPassword = await bcryptjs.hash(req.body.password, 8);

    const updatedUserPwd = await User.findOneAndUpdate(
      {
        email: req.body.email,
      },
      { $set: { password: hashPassword } }
    ).exec();

    if (!updatedUserPwd) {
      res.status(400).json({ msg: "Password is not updated" });
    } else {
      res.status(200).json(updatedUserPwd);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// send reference book data to the database
authRouter.post("/api/uploadBook", upload.single("img"), async (req, res) => {
  try {
    // check if the request has an image or not
    if (!req.file) {
      return res.status(400).json({ msg: "You must provide an image! " });
    } else {
      let uploadImg = {
        img: req.file.path,
        title: req.body.title,
        authName: req.body.authName,
        genre: req.body.genre.split(",").map((genre) => genre.trim()),
        price: req.body.price,
        pageNum: req.body.pageNum,
        description: req.body.description,
      };
      // create an User object to be stored
      let book = new Book(uploadImg);
      // saving the object to database
      book = await book.save();

      // send User to client
      res.json(book);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// retrieve reference book data from the database based on the Navigation-Categories
authRouter.get("/api/retrieveBook/:genre", async (req, res) => {
  try {
    // get the genre from the req
    const genre = req.params.genre;

    const books = await Book.find({ genre: { $in: [genre] } });

    if (books.length === 0) {
      return res.status(400).json({ msg: "No books for this category!" });
    }
    // return res.status(400).json({ msg: "You must provide an image! "});
    res.json(books);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// retrieve one book with ID
authRouter.get("/api/retrieveOneBook/:_id", async (req, res) => {
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

// to create a wishlist with quantity of 1 (user_id, book_id, quantity, price)
authRouter.post("/api/createWishlist", async (req, res) => {
  try {
    // check whether the wishlist is in the database, if yes, only
    // edit the quantity
    // else, create a new one

    const wishtlistExist = await Wishlist.findOne({
      user_id: req.body.user_id,
      book_id: req.body.book_id,
    }).exec();
    // crete a new one
    if (!wishtlistExist) {
      const newWishlist = new Wishlist({
        user_id: req.body.user_id,
        book_id: req.body.book_id,
        quantity: 1,
        price: req.body.price,
      });

      console.log(req.body.user_id);
      console.log(req.body.book_id);
      console.log(req.body.price);

      let wishlist = await newWishlist.save();

      res.json(wishlist);
    } else {
      // edit the quantity
      const updatedWishlist = await Wishlist.findOneAndUpdate(
        {
          user_id: req.body.user_id,
          book_id: req.body.book_id,
        },
        { $set: { quantity: req.body.quantity } },
        { new: true }
      ).exec();

      if (!updatedWishlist) {
        res.status(400).json({ msg: "Quantity is not updated" });
      } else {
        res.status(200).json(updatedWishlist);
      }
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// delete the wishlist item (user_id)
authRouter.post("/api/deleteOneWishlist", async (req, res) => {
  try {
    await Wishlist.deleteOne({
      user_id: req.body.user_id,
      book_id: req.body.book_id,
    });
    res.status(200).json({ msg: "Wishlist deleted successfully" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// delete multiple wishlist at once
authRouter.post("/api/deleteMultipleWishlist", async (req, res) => {
  try {
    const user_id = req.body.user_id;
    const book_ids = req.body.book_ids; // Array of book_id values to be deleted

    await Wishlist.deleteMany({ user_id: user_id, book_id: { $in: book_ids } });

    res.status(200).json({ msg: "Wishlist items deleted successfully" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get all wishlist item (user_id)
authRouter.get("/api/getAllWishlist/:user_id", async (req, res) => {
  try {
    const wishlistItems = await Wishlist.find({
      user_id: req.params.user_id,
    }).exec();

    if (wishlistItems.length === 0) {
      res.status(404).json({ msg: "No wishlist items found" });
    } else {
      res.json(wishlistItems);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get the specific wishlist item (book_id, user_id)
authRouter.get("/api/getOneWishlist/:user_id/:book_id", async (req, res) => {
  try {
    const wishtlistItem = await Wishlist.findOne({
      user_id: req.params.user_id,
      book_id: req.params.book_id,
    }).exec();

    // get the item
    if (wishtlistItem) {
      res.json(wishtlistItem);
    } else {
      res.status(400).json({ msg: "Wishlist item not found" });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/// need change for scanned devices
// create the user visit (post)
// when the door scanner scan only create (when go out and scan,
// only update the end date and duration)
// but for now, auto create and generate
authRouter.post("/api/createUserVisit", async (req, res) => {
  try {
    const timeZoneOptions = { timeZone: "Asia/Kuala_Lumpur" };

    // Create the current date and time in Malaysia
    const startDate = new Date().toLocaleString("en-US", timeZoneOptions);
    const endDate = new Date();
    endDate.setHours(endDate.getHours() + 1);
    endDate.setMinutes(endDate.getMinutes() + 29);
    endDate.setSeconds(endDate.getSeconds() + 35);
    const endDateString = endDate.toLocaleString("en-US", timeZoneOptions);

    const newUserVisit = new UserVisit({
      user_id: req.body.user_id,
      start_datetime: startDate,
      end_datetime: endDateString,
      duration: 1 * 3600 + 29 * 60 + 35,
    });

    let userVisit = await newUserVisit.save();

    res.json(userVisit);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// in payment, use user_id to get userVisit start_datetime
// where end_datetime = ''
authRouter.get("/api/getExitUserVisitStartDate/:user_id", async (req, res) => {
  try {
    const userVisitItem = await UserVisit.findOne({
      user_id: req.params.user_id,
      end_datetime: "",
    }).exec();

    if (userVisitItem) {
      res.json({ start_datetime: userVisitItem.start_datetime });
    } else {
      res.json({});
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// in payment, create update the end datetime and duration
// of the latest userVisit
authRouter.post("/api/createExitUserVisit", async (req, res) => {
  try {
    const user_id = req.body.user_id;
    const timeZoneOptions = { timeZone: "Asia/Kuala_Lumpur" };

    // Create the current date and time in Malaysia
    const endDate = new Date().toLocaleString("en-US", timeZoneOptions);

    // Find the UserVisit record with the specified user_id and empty end_datetime
    const userVisit = await UserVisit.findOneAndUpdate(
      { user_id: user_id, end_datetime: "" },
      {
        end_datetime: endDate,
        duration: Math.floor(
          (new Date(endDate) - new Date(req.body.start_datetime)) / 1000
        ),
      },
      { new: true }
    );

    if (userVisit) {
      res.json(userVisit);
    } else {
      res.status(400).json({ msg: "UserVisit not found or already updated" });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get the on going userVisit id (already enter but haven't exit)
authRouter.get("/api/getExitUserVisitId/:user_id", async (req, res) => {
  try {
    const userVisitItem = await UserVisit.findOne({
      user_id: req.params.user_id,
      end_datetime: '',
    }).exec();

    if (userVisitItem) {
      res.json({ userVisit_id: userVisitItem._id });
    } else {
      res.json({});
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// get the latest user visit by using user.id, if it is blank, then it
// return blank user visit (get request)
authRouter.get("/api/getLatestDuration/:user_id", async (req, res) => {
  try {
    const userVisitItem = await UserVisit.findOne({
      user_id: req.params.user_id,
      end_datetime: { $ne: '' },
    })
      .sort({ end_datetime: -1 })
      .limit(1)
      .exec();

    // Get the item
    if (userVisitItem) {
      const durationInSeconds = userVisitItem.duration;
      const hours = Math.floor(durationInSeconds / 3600);
      const minutes = Math.floor((durationInSeconds % 3600) / 60);
      const seconds = durationInSeconds % 60;

      var durationString = "";
      if (hours > 0) {
        durationString += `${hours} ${hours > 1 ? "hours" : "hour"}`;
        if (minutes > 0 || seconds > 0) {
          durationString += ` ${minutes} ${minutes > 1 ? "minutes" : "minute"}`;
        }
        if (seconds > 0) {
          durationString += ` ${seconds} ${seconds > 1 ? "seconds" : "second"}`;
        }
      } else if (minutes > 0) {
        durationString += `${minutes} ${minutes > 1 ? "minutes" : "minute"}`;
        if (seconds > 0) {
          durationString += ` ${seconds} ${seconds > 1 ? "seconds" : "second"}`;
        }
      } else {
        durationString += `${seconds} ${seconds > 1 ? "seconds" : "second"}`;
      }

      res.json({ duration: durationString });
    } else {
      res.json({duration: '0'});
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// create user QR, with user.id,random number and encrypted QRCod String
// post request
authRouter.post("/api/createQRKey", async (req, res) => {
  try {
    const QRKeyExist = await QRKey.findOne({
      user_id: req.body.user_id,
    }).exec();
    // crete a new one
    if (!QRKeyExist) {
      const newQRKey = new QRKey({
        user_id: req.body.user_id,
        qrStr: req.body.qrStr,
      });

      let qrKey = await newQRKey.save();

      res.json(qrKey);
    } else {
      // edit the quantity
      const updatedQRKey = await QRKey.findOneAndUpdate(
        {
          user_id: req.body.user_id,
        },
        { $set: { qrStr: req.body.qrStr } },
        { new: true }
      ).exec();

      if (!updatedQRKey) {
        res.status(400).json({ msg: "QRKey is not updated" });
      } else {
        res.status(200).json(updatedQRKey);
      }
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get the user QR (get request)
authRouter.get("/api/getQRKey/:user_id", async (req, res) => {
  try {
    const qrKeyItem = await QRKey.findOne({
      user_id: req.params.user_id,
    }).exec();

    // get the item
    if (qrKeyItem) {
      res.json(qrKeyItem);
    } else {
      res.status(400).json({ msg: "QRKey not found" });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// once reach receipt page, use the user id to get all userVisit
authRouter.get("/api/getAllUserVisit/:user_id", async (req, res) => {
  try {
    const userVisitItems = await UserVisit.find({
      user_id: req.params.user_id,
      end_datetime: { $ne: "" } 
    }).exec();

    const sortedUserVisitItems = userVisitItems.sort((a, b) => {
      const dateA = moment(a.start_datetime, "MM/DD/YYYY, h:mm:ss A");
      const dateB = moment(b.start_datetime, "MM/DD/YYYY, h:mm:ss A");
      return dateB - dateA; // Sort in descending order
    });

    if (sortedUserVisitItems.length === 0) {
      res.status(404).json({ msg: "No user visit record found" });
    } else {
      res.json(sortedUserVisitItems);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/// need change for scanned devices (now is for manual)
// create payment (when stuff qr code and detect is not user id, is scanned, record in list first,
// then when the user id qr code is scanned, ask user to pay
// , if user allow to pay and have enough money in digital wallet)
// only record the end time in userVisit, calculate the duration and
// record the payment
// for currently, I want to create using userVisit id (no need to validate)
authRouter.post("/api/createPayment", async (req, res) => {
  try {
    const newPayment = new Payment({
      userVisit_id: req.body.userVisit_id,
      bookIdList: req.body.bookIdList,
      quantityList: req.body.quantityList,
      priceList: req.body.priceList,
      subtotal: req.body.subtotal,
      estimatedTax: req.body.estimatedTax,
      total: req.body.total,
      status: req.body.status,
    });

    let payment = await newPayment.save();

    res.json(payment);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get payment details using userVisitid
authRouter.get("/api/getPayments/:userVisitIds", async (req, res) => {
  try {
    const userVisitIds = req.params.userVisitIds.split(",");

    if (!userVisitIds || userVisitIds.length === 0) {
      res.json([]);
      return;
    }

    const payments = await Payment.find({
      userVisit_id: { $in: userVisitIds },
    }).exec();

    res.json(payments);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get one user visit duration
authRouter.get("/api/getUserVisitDuration/:userVisit_id", async (req, res) => {
  try {
    const userVisitItem = await UserVisit.findOne({
      _id: req.params.userVisit_id,
    }).exec();

    // Get the item
    if (userVisitItem) {
      const durationInSeconds = userVisitItem.duration;
      const hours = Math.floor(durationInSeconds / 3600);
      const minutes = Math.floor((durationInSeconds % 3600) / 60);
      const seconds = durationInSeconds % 60;

      var durationString = "";
      if (hours > 0) {
        durationString += `${hours} ${hours > 1 ? "hours" : "hour"}`;
        if (minutes > 0 || seconds > 0) {
          durationString += ` ${minutes} ${minutes > 1 ? "minutes" : "minute"}`;
        }
        if (seconds > 0) {
          durationString += ` ${seconds} ${seconds > 1 ? "seconds" : "second"}`;
        }
      } else if (minutes > 0) {
        durationString += `${minutes} ${minutes > 1 ? "minutes" : "minute"}`;
        if (seconds > 0) {
          durationString += ` ${seconds} ${seconds > 1 ? "seconds" : "second"}`;
        }
      } else {
        durationString += `${seconds} ${seconds > 1 ? "seconds" : "second"}`;
      }

      res.json({ duration: durationString });
    } else {
      res.json({});
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// when go to Receipt detail page, user the list of book.id to retrieve
// book details.
authRouter.get("/api/getBooks/:bookIds", async (req, res) => {
  try {
    const bookIds = req.params.bookIds.split(",");

    const books = await Book.find({
      _id: { $in: bookIds },
    });

    res.json(books);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});



// check if there is the user_id, if no create one, else, return
// post create the userBalance table with userid and total balance = 0.0
authRouter.post("/api/createUserBalance", async (req, res) => {
  try {
    const userBalanceExist = await UserBalance.findOne({
      user_id: req.body.user_id,
    }).exec();

    if (!userBalanceExist) {
      const newUserBalance = new UserBalance({
        user_id: req.body.user_id,
        totalBalance: req.body.totalBalance,
      });

      let userBalance = await newUserBalance.save();

      res.json(userBalance);
    } else {
      res.json({}); // Return an empty UserBalance object
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get request to get total balance using user_id
authRouter.get("/api/getUserBalance/:user_id", async (req, res) => {
  try {
    const userBalanceItem = await UserBalance.findOne({
      user_id: req.params.user_id,
    }).exec();

    // get the item
    if (userBalanceItem) {
      res.json(userBalanceItem);
    } else {
      res.status(400).json({ msg: "User Balance not found" });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// post to update the userBalance using the user_id
// calculate the totalBalance then only pass into this API
authRouter.post("/api/updateUserBalance", async (req, res) => {
  try {
    const updatedBalance = await UserBalance.findOneAndUpdate(
      {
        user_id: req.body.user_id,
      },
      { $set: { totalBalance: req.body.totalBalance } }
    ).exec();

    if (!updatedBalance) {
      res.status(400).json({ msg: "Balance is not updated" });
    } else {
      res.status(200).json(updatedBalance);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// when press deposit or pay button, if success, update the
// transaction history table
// when deposit is pressed, if no user_id, create one
// if got user_id, update one, type is res.body.transactionType
// now is just dummy, so is to deposit into database
// update userBalance and TransactionHistory table

// create the payment qrcode
authRouter.post("/api/createPaymentQRKey", async (req, res) => {
  try {
    const PaymentQRKeyExist = await PaymentQRKey.findOne({
      user_id: req.body.user_id,
    }).exec();
    // crete a new one
    if (!PaymentQRKeyExist) {
      const newPaymentQRKey = new PaymentQRKey({
        user_id: req.body.user_id,
        qrStr: req.body.qrStr,
      });

      let paymentQRKey = await newPaymentQRKey.save();

      res.json(paymentQRKey);
    } else {
      // edit the qrstr
      const updatedPaymentQRKey = await PaymentQRKey.findOneAndUpdate(
        {
          user_id: req.body.user_id,
        },
        { $set: { qrStr: req.body.qrStr } },
        { new: true }
      ).exec();

      if (!updatedPaymentQRKey) {
        res.status(400).json({ msg: "PaymentQRKey is not updated" });
      } else {
        res.status(200).json(updatedPaymentQRKey);
      }
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get the user QR (get request)
authRouter.get("/api/getPaymentQRKey/:user_id", async (req, res) => {
  try {
    const paymentQRKeyItem = await PaymentQRKey.findOne({
      user_id: req.params.user_id,
    }).exec();

    // get the item
    if (paymentQRKeyItem) {
      res.json(paymentQRKeyItem);
    } else {
      res.status(400).json({ msg: "PaymentQRKey not found" });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// update user name
authRouter.post("/api/updateUserName", async (req, res) => {
  try {
    const updatedUserName = await User.findOneAndUpdate(
      {
        _id: req.body.user_id,
      },
      { $set: { name: req.body.name } }
    ).exec();

    if (!updatedUserName) {
      res.status(400).json({ msg: "Name is not updated" });
    } else {
      res.status(200).json(updatedUserName);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// update user email
authRouter.post("/api/updateUserEmail", async (req, res) => {
  try {
    const updatedUserEmail = await User.findOneAndUpdate(
      {
        _id: req.body.user_id,
      },
      { $set: { email: req.body.email } }
    ).exec();

    if (!updatedUserEmail) {
      res.status(400).json({ msg: "Email is not updated" });
    } else {
      res.status(200).json(updatedUserEmail);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// validate the entered original password
authRouter.post("/api/validPwd", async (req, res) => {
  try {
    const { email, password } = req.body;

    // validate email
    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exist!" });
    }

    // validate password (using user object that is got from findOne email)
    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Password not matching!" });
    }

    // get the token for the User so that can be used in every page
    res.status(200).json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// update the user password
authRouter.post("/api/updateUserPwd", async (req, res) => {
  try {
    const hashPassword = await bcryptjs.hash(req.body.password, 8);

    const updatedUserPwd = await User.findOneAndUpdate(
      {
        _id: req.body.user_id,
      },
      { $set: { password: hashPassword } }
    ).exec();

    if (!updatedUserPwd) {
      res.status(400).json({ msg: "Password is not updated" });
    } else {
      res.status(200).json(updatedUserPwd);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// create the transaction history, transaction type : "Deposit" / "Pay"
authRouter.post("/api/createTransactionHistory", async (req, res) => {
  try {
    const timeZoneOptions = { timeZone: "Asia/Kuala_Lumpur" };

    // Create the current date and time in Malaysia
    const startDate = new Date().toLocaleString("en-US", timeZoneOptions);

    const newTransaction = new TransactionHistory({
      user_id: req.body.user_id,
      transaction_datetime: startDate,
      amount: req.body.amount,
      transactionType: req.body.transactionType,
    });

    let transaction = await newTransaction.save();

    res.json(transaction);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// when get the transaction history, arrange the date in descending order
authRouter.get("/api/getTransactionHistory/:user_id", async (req, res) => {
  try {
    const user_id = req.params.user_id;

    const transactionHistories = await TransactionHistory.find({ user_id })
      .sort({ _id: -1 })
      .exec();

    // Convert transaction_datetime strings to actual Date objects
    const sortedHistories = transactionHistories.map((history) => {
      const { transaction_datetime, ...rest } = history.toObject();
      return {
        ...rest,
        transaction_datetime: new Date(transaction_datetime),
      };
    });

    res.json(sortedHistories);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// create discount (use the uploadbook post request)
authRouter.post(
  "/api/uploadDiscount",
  upload.single("img"),
  async (req, res) => {
    try {
      // check if the request has an image or not
      if (!req.file) {
        return res.status(400).json({ msg: "You must provide an image! " });
      } else {
        let uploadImg = {
          img: req.file.path,
          title: req.body.title,
          subtitle: req.body.subtitle,
          genre: req.body.genre.split(",").map((genre) => genre.trim()),
          maxPrice: req.body.maxPrice,
          mustOverMaxPrice: req.body.mustOverMaxPrice,
          discountPercent: req.body.discountPercent,
        };
        // create an User object to be stored
        let discount = new Discount(uploadImg);
        // saving the object to database
        discount = await discount.save();

        // send User to client
        res.json(discount);
      }
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  }
);

// create usedDiscount
authRouter.post("/api/createUsedDiscount", async (req, res) => {
  try {
    const newUsedDiscount = new UsedDiscount({
      user_id: req.body.user_id,
      discount_id: req.body.discount_id,
    });

    let usedDiscount = await newUsedDiscount.save();

    res.json(usedDiscount);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get the usedDiscount list of Discountid based on the userid
authRouter.get("/api/getAllUsedDiscount/:user_id", async (req, res) => {
  try {
    const usedDiscountItems = await UsedDiscount.find({
      user_id: req.params.user_id,
    }).exec();

    if (usedDiscountItems.length === 0) {
      res.json([]); // Return an empty array when no discount has been used
    } else {
      const discountIds = usedDiscountItems.map((item) => item.discount_id);
      res.json(discountIds); // Return the list of discount_ids
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// input the list of discountid,
// get the discount, only get the discount that is not in the list
authRouter.get("/api/retrieveDiscount/:usedDiscountIds", async (req, res) => {
  try {
    const usedDiscountIds = req.params.usedDiscountIds.split(",");

    let discounts;

    if (usedDiscountIds.length === 1 && usedDiscountIds[0] === "0") {
      discounts = await Discount.find();
    } else {
      discounts = await Discount.find({ _id: { $nin: usedDiscountIds } });
    }

    if (discounts.length === 0) {
      return res.json([]);
    }

    res.json(discounts);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// during the exit
// parameter = rfid_id
// use the rfid_id to get a ScannedProduct object
authRouter.get("/api/getOneScannedProduct/:rfid_id", async (req, res) => {
  try {
    const rfidId = req.params.rfid_id;

    const scannedProduct = await ScannedProduct.findOne({
      rfid_id: rfidId,
    }).exec();

    if (scannedProduct) {
      res.json({ scannedProduct });
    } else {
      res.status(404).json({ msg: "Scanned Product not found" });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// during exit, got discount
// input discountIds to retrieve a list of discounts
authRouter.get("/api/getExitDiscountList/:discountIds", async (req, res) => {
  try {
    const discountIds = req.params.discountIds.split(",");

    let discountList;

    discountList = await Discount.find({ _id: { $in: discountIds } });

    res.json(discountList);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// during exit, delete the scannedProduct
// input rfid_id to delete it
authRouter.post("/api/deleteOneScannedProduct", async (req, res) => {
  try {
    await ScannedProduct.deleteOne({
      rfid_id: req.body.rfid_id,
    });
    res.status(200).json({ msg: "Scanned Product deleted successfully" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// during exit, delete the wishlist item based on the user_id, bookIdList, quantityList
authRouter.post("/api/updateExitWishlistItem", async (req, res) => {
  try {
    const userId = req.body.user_id;
    const bookIdList = req.body.bookIdList;
    const quantityList = req.body.quantityList;

    const wishlistItems = await Wishlist.find({
      user_id: userId,
      book_id: { $in: bookIdList },
    });

    for (const wishlistItem of wishlistItems) {
      const index = bookIdList.indexOf(wishlistItem.book_id);
      const quantity = wishlistItem.quantity - parseInt(quantityList[index]);

      if (quantity <= 0) {
        // Delete the wishlist item if quantity is zero or negative
        await Wishlist.deleteOne({ _id: wishlistItem._id });
      } else {
        // Update the wishlist item with the new quantity
        wishlistItem.quantity = quantity;
        await wishlistItem.save();
      }
    }

    res.status(200).json({ msg: "Wishlist updated successfully" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// recommendation
// store the clicked book details everytime book is clicked
authRouter.post("/api/createUserClickedBook", async (req, res) => {
  try {
    const timeZoneOptions = { timeZone: "Asia/Kuala_Lumpur" };
    const clicked_datetime = new Date().toLocaleString("en-US", timeZoneOptions);

    const userClickedBook = await UserClickedBook.findOne({ user_id: req.body.user_id });

    if (userClickedBook) {
      userClickedBook.genreList.push(req.body.genreList);
      userClickedBook.clicked_datetime.push(clicked_datetime);
      await userClickedBook.save();
    } else {
      const newUserClickedBook = new UserClickedBook({
        user_id: req.body.user_id,
        genreList: [req.body.genreList],
        clicked_datetime: [clicked_datetime],
      });
      await newUserClickedBook.save();
    }

    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// get the userClickedBooks based on user_id
authRouter.get("/api/getUserClickedBooks/:user_id", async (req, res) => {
  try {
    const { user_id } = req.params;
    const userClickedBooks = await UserClickedBook.find({ user_id });

    if (userClickedBooks && userClickedBooks.length > 0) {
      res.json(userClickedBooks);
    } else {
      res.json([]);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// recommendation page
// take in a list of genre
// find from book table where the book is in the genre
// return the book list
authRouter.get("/api/retrieveRecommendBookList/:genreList", async (req, res) => {
  try {
    // Get the genre list from the request
    const genreList = req.params.genreList;

    // Split the genre list into an array
    const genres = genreList.split(',');

    const books = await Book.find({ genre: { $in: genres } });

    if (books.length === 0) {
      return res.status(400).json({ msg: "No books for this category!" });
    }

    // Filter books that match at least half of the genre list
    const filteredBooks = books.filter((book) => {
      const matchedGenres = book.genre.filter((bookGenre) =>
        genres.includes(bookGenre)
      );
      return matchedGenres.length >= Math.ceil(genres.length / 2);
    });

    // Shuffle the filtered books randomly
    const shuffledBooks = lodash.shuffle(filteredBooks);

    res.json(shuffledBooks);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = authRouter;