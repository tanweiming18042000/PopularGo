const express = require("express");
const User = require("../models/user");
const UserVisit = require("../models/userVisit");
const QRKey = require("../models/qrKey");

const enterRouter = express.Router();

// get request
// use APi to compare qrStr to the database
// get the user_id

enterRouter.get("/api/getUserId/:qrStr", async (req, res) => {
  try {
    const qrKeyItem = await QRKey.findOne({
      qrStr: req.params.qrStr,
    }).exec();

    // get the item
    if (qrKeyItem) {
      // get the userid
      const userId = qrKeyItem.user_id;
      res.json({ user_id: userId });
    } else {
      res.status(400).json({ msg: "QRKey not found" });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// post request
// use the user_id to craete a new userVisit with only the start_datetime
enterRouter.post("/api/createEnterUserVisit", async (req, res) => {
  try {
    const user_id = req.body.user_id;
    const timeZoneOptions = { timeZone: "Asia/Kuala_Lumpur" };

    // Create the current date and time in Malaysia
    const startDate = new Date().toLocaleString("en-US", timeZoneOptions);

    const newUserVisit = new UserVisit({ 
        user_id: user_id, 
        start_datetime: startDate,
        end_datetime: '',
        duration: 0,    
    });

    let userVisit = await newUserVisit.save();

    res.json(userVisit);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = enterRouter;
