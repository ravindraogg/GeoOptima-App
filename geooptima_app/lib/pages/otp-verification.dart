import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // Replace the single controller with a list of controllers
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _otpFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Add a method to get the complete OTP
  String get completeOtp {
    return _otpControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Use these dimensions to calculate responsive sizes
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
            // Polygon image / G background
             Positioned(
              left: -4,
              top: 0,
              child: Image.asset(
                'assets/poly2.png',
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    color: Colors.red,
                    child: const Center(child: Text('Image Error')),
                  );
                },
              ),
            ),
            // G text
            Positioned(
              left: screenWidth * 0.00,
              top: screenHeight * -0.02,
              child: GestureDetector(
                onTap: () {
                  debugPrint('Back button tapped');
                  Navigator.pop(context); // Navigates back to the previous screen
                },
                child: Container(
                  padding: EdgeInsets.all(10 * widthRatio),
                  child: Text(
                    'G',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: screenWidth * 0.16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
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
            
            // Enter your OTP text
            Positioned(
              left: 27 * widthRatio,
              top: 437 * heightRatio,
              child: Text(
                'Enter your OTP',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 20 * widthRatio,
                  fontWeight: FontWeight.w500,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 75 * widthRatio,
                      height: 67 * heightRatio,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD9D9D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15 * widthRatio),
                        ),
                      ),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        onChanged: (value) {
                          // Auto-focus to next field when a digit is entered
                          if (value.length == 1 && index < 3) {
                            FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
                          }
                        },
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '', // Hide the counter
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10 * widthRatio,
                            vertical: 15 * heightRatio,
                          ),
                        ),
                        style: GoogleFonts.montserrat(
                          fontSize: 24 * widthRatio,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
Positioned(
  left: 264 * widthRatio,
  top: 601 * heightRatio,
  child: GestureDetector(
    onTap: () {
      // Process OTP verification
      final otp = completeOtp;
      if (otp.length == 4) {
        debugPrint('OTP submitted for verification: $otp');
        // Add your OTP verification logic here
      } else {
        // Show error if OTP is incomplete
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter complete OTP code')),
        );
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
      child: Center(
        child: Text(
          'Verify',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 20 * widthRatio,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  ),
),
            // Resend code option with black color
            Positioned(
              left: 27 * widthRatio,
              top: 615 * heightRatio,
              child: GestureDetector(
                onTap: () {
                  // Add resend code logic here
                  debugPrint('Resend code requested');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP code resent')),
                  );
                },
                child: Text(
                  'Resend code',
                  style: GoogleFonts.montserrat(
                    color: Colors.black, // Changed from blue to black
                    fontSize: 16 * widthRatio,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}