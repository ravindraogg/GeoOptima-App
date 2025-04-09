import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Use these dimensions to calculate responsive sizes
    // Base design was for 402x874, now we'll make it proportional
    final widthRatio = screenWidth / 402;
    final heightRatio = screenHeight / 874;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // G Text
            Positioned(
              left: 19 * widthRatio,
              top: 9 * heightRatio,
              child: Text(
                'G',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 64 * widthRatio,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
            // Rotated black shape
            Positioned(
              left: 361.93 * widthRatio,
              top: -206.18 * heightRatio,
              child: Transform(
                transform: Matrix4.identity()..rotateZ(1.16),
                child: Container(
                  width: 511 * widthRatio,
                  height: 297 * heightRatio,
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50 * widthRatio),
                    ),
                  ),
                ),
              ),
            ),
            
            // Rotated white shape
            Positioned(
              left: 246 * widthRatio,
              top: -22.14 * heightRatio,
              child: Transform(
                transform: Matrix4.identity()..rotateZ(-0.44),
                child: Container(
                  width: 131.39 * widthRatio,
                  height: 240.08 * heightRatio,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40 * widthRatio),
                        bottomLeft: Radius.circular(40 * widthRatio),
                        bottomRight: Radius.circular(40 * widthRatio),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Let's get you moving text
            Positioned(
              left: 19 * widthRatio,
              top: 195 * heightRatio,
              child: SizedBox(
                width: 269 * widthRatio,
                height: 156 * heightRatio,
                child: Text(
                  'Let\'s \nget you moving',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 50 * widthRatio,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            
            // OTP TextField container
            Positioned(
              left: 27 * widthRatio,
              top: 477 * heightRatio,
              child: Container(
                width: 347 * widthRatio,
                height: 67 * heightRatio,
                decoration: ShapeDecoration(
                  color: const Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30 * widthRatio),
                  ),
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: 30 * widthRatio,
                      bottom: 15 * heightRatio,
                    ),
                    hintText: '',
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: 20 * widthRatio,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            // Verify button container
            Positioned(
              left: 264 * widthRatio,
              top: 601 * heightRatio,
              child: GestureDetector(
                onTap: () {
                  // Process OTP verification
                  if (_otpController.text.isNotEmpty) {
                    debugPrint('OTP submitted for verification: ${_otpController.text}');
                    // Add your OTP verification logic here
                  }
                },
                child: Container(
                  width: 110 * widthRatio,
                  height: 51 * heightRatio,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 3 * widthRatio),
                      borderRadius: BorderRadius.circular(30 * widthRatio),
                    ),
                  ),
                ),
              ),
            ),
            
            // Enter your OTP text
            Positioned(
              left: 57 * widthRatio,
              top: 499 * heightRatio,
              child: Text(
                'Enter your otp.....',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 20 * widthRatio,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Verify text
            Positioned(
              left: 290 * widthRatio,
              top: 615 * heightRatio,
              child: Text(
                'Verify',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 20 * widthRatio,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}