const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { generateOTP } = require('../utils/otpGenerator');
const { sendSMS } = require('../utils/sendSMS');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const generateOTPAndSave = async (phoneNumber) => {
  const otp = generateOTP();
  const hashedOTP = await bcrypt.hash(otp, 10);
  const otpExpires = new Date(Date.now() + 10 * 60 * 1000);

  let user = await User.findOne({ phoneNumber });
  if (user) {
    user.otp = hashedOTP;
    user.otpExpires = otpExpires;
  } else {
    user = new User({ phoneNumber, otp: hashedOTP, otpExpires });
  }
  await user.save();
  await sendSMS(phoneNumber, otp);
  return { message: 'OTP sent successfully via SMS' };
};

// Register - Generate OTP for new user
router.post('/register', async (req, res) => {
    const { phoneNumber } = req.body;
    const otp = Math.floor(1000 + Math.random() * 9000).toString(); // 4-digit OTP
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes expiry
  
    const user = new User({ phoneNumber, otp, otpExpires });
    await user.save();
  
    res.status(200).json({ message: `OTP ${otp} sent to ${phoneNumber}` });
  });

  router.post('/login', async (req, res) => {
    const { phoneNumber } = req.body;
  
    try {
      let user = await User.findOne({ phoneNumber });
      if (!user) return res.status(404).json({ error: 'User not found' });
  
      // Generate and store OTP
      const otp = Math.floor(1000 + Math.random() * 9000).toString(); // 4-digit OTP
      const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes expiry
  
      user.otp = otp;
      user.otpExpires = otpExpires;
      await user.save();
  
      res.status(200).json({ message: `OTP ${otp} sent to ${phoneNumber}` });
    } catch (error) {
      res.status(500).json({ error: 'Server error' });
    }
  });
  router.post('/verify-otp', async (req, res) => {
    const { phoneNumber, otp, otpExpires } = req.body;
  
    try {
      const user = await User.findOne({ phoneNumber });
      if (!user) return res.status(404).json({ error: 'User not found' });
  
      console.log('Received OTP:', otp);
      console.log('Stored OTP:', user.otp);
      console.log('Received otpExpires:', otpExpires);
      console.log('Stored otpExpires:', user.otpExpires);
  
      if (!user.otp || user.otp !== otp) {
        return res.status(400).json({ error: 'Invalid OTP' });
      }
  
      if (!user.otpExpires || new Date() > user.otpExpires) {
        return res.status(400).json({ error: 'OTP has expired' });
      }
  
      // On success
      user.otp = undefined;
      user.otpExpires = undefined;
      await user.save();
  
      res.status(200).json({ message: 'OTP verified successfully', token: 'your-jwt-token-here' });
    } catch (error) {
      res.status(500).json({ error: 'Server error' });
    }
  });
module.exports = router;