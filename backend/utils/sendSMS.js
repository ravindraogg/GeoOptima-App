const sendSMS = async (phoneNumber, otp) => {
    try {
      console.log(`OTP for ${phoneNumber}: ${otp}. Please copy this and use it in the app for verification.`);
      // OTP is logged to the console; you can manually send it to your phone or enter it directly
    } catch (error) {
      console.error('Error logging OTP:', error);
      throw new Error('Failed to log OTP');
    }
  };
  
  module.exports = { sendSMS };