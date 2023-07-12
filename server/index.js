const express = require("express");
const mongoose = require("mongoose");
const app = express();
const httpServer = require("http").createServer(app);
const io = require("socket.io")(httpServer);

// imports from other files
const authRouter = require("./routes/auth.js");
const enterRouter = require("./routes/enter.js");
const productScanRouter = require("./routes/productScan.js");
const exitRouter = require("./routes/exit.js");

// Initialisation
const PORT = 3000;
// const app = express();
const DB =
  [MongoDB API];

// middleware (runs everytime a request is fired)
app.use(express.json());
app.use(authRouter);
app.use(enterRouter);
app.use(productScanRouter);
app.use(exitRouter);
app.use("/uploads", express.static("./uploads"));

// connections to database
mongoose
  .connect(DB)
  .then(() => {
    console.log("Database connection successful");
  })
  .catch((e) => {
    console.log("Database connection error:", e);
  });

io.on("connection", (socket) => {
  console.log("New client connected");

  socket.on("qrcode", (data) => {
    console.log("Received QR code:", data.qrCode);
    io.emit("qrcode_response", { qrCode: data.qrCode });
    console.log("Response emitted");
  });

  // from exitScanner if no purchase from customer
  socket.on("no_purchases", (data) => {
    // mobile received this and update endDate, duration and go to noPurchasePage
    io.emit("customer_no_purchase", { purchaseNum: data.purchaseNum });
    console.log("Customer No purchase emitted");
  });

  // from exitScanner if got purchase but no unusedDiscount
  socket.on("no_unused_discounts", (data) => {
    // mobile received this, straight go to receipt checkoout page
    // use the rfid_id to get everything, then use the bookIdList
    // to get the books from the database
    // display the receipt with book title, authname
    // quantity, price, subtotal, estimatedTax, total
    // like the receipt detail page'
    console.log('no used discount emitted');
    io.emit("customer_no_unused_discounts", {
      rfid_id: data.rfid_id,
      unusedDiscountIds: data.unusedDiscountIds,
    });
  });

  socket.on("have_unused_discount", (data) => {
    // mobile received this, straight go to receipt checkoout page
    // use the rfid_id to get everything, then use the bookIdList
    // to get the books from the database
    // display the receipt with book title, authname
    // quantity, price, subtotal, estimatedTax, total
    // like the receipt detail page'
    console.log('have unused discount emitted');
    io.emit("customer_have_unused_discounts", {
      rfid_id: data.rfid_id,
      unusedDiscountIds: data.unusedDiscountIds,
    });
  });

  // done everything, can produce the correct sound
  socket.on("done_exit", (_) => {
    // Server received 'done_exit', emit 'correct_sound'
    io.emit("correct_sound");
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected");
  });
});

httpServer.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
