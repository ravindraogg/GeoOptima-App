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
  if (!phoneNumber) return res.status(400).json({ error: 'Phone number is required' });

  try {
    const existingUser = await User.findOne({ phoneNumber });
    if (existingUser) {
      return res.status(400).json({ error: 'Phone number already registered' });
    }

    const { message } = await generateOTPAndSave(phoneNumber);
    res.status(200).json({ message });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Login - Generate OTP for existing user
router.post('/login', async (req, res) => {
  const { phoneNumber } = req.body;
  if (!phoneNumber) return res.status(400).json({ error: 'Phone number is required' });

  try {
    const user = await User.findOne({ phoneNumber });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const { message } = await generateOTPAndSave(phoneNumber);
    res.status(200).json({ message });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Verify OTP
router.post('/verify-otp', async (req, res) => {
  const { phoneNumber, otp } = req.body;

  try {
    const user = await User.findOne({ phoneNumber });
    if (!user) return res.status(404).json({ error: 'User not found' });

    console.log('Received OTP:', otp);
    console.log('Stored OTP:', user.otp);
    console.log('Stored otpExpires:', user.otpExpires);

    if (!user.otp || !(await bcrypt.compare(otp, user.otp))) {
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    if (!user.otpExpires || new Date() > user.otpExpires) {
      return res.status(400).json({ error: 'OTP has expired' });
    }

    // On success
    user.otp = undefined;
    user.otpExpires = undefined;
    user.isVerified = true;
    await user.save();

    const token = jwt.sign({ phoneNumber: user.phoneNumber }, 'your-secret-key', { expiresIn: '1h' });
    res.status(200).json({ message: 'OTP verified successfully', token });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

router.post('/complete-registration', async (req, res) => {
  const { phoneNumber, fullName, email, gender, dateOfBirth } = req.body;

  try {
    let user = await User.findOne({ phoneNumber });
    if (!user) return res.status(404).json({ error: 'User not found' });
    if (!user.isVerified) return res.status(400).json({ error: 'Phone number not verified' });

    user.fullName = fullName;
    user.email = email;
    user.gender = gender;
    user.dateOfBirth = dateOfBirth;
    await user.save();

    const token = jwt.sign({ phoneNumber, email }, 'your-secret-key', { expiresIn: '1h' });
    res.status(200).json({ message: 'Account created successfully', token });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;