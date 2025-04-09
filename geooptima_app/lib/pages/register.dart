import 'package:flutter/material.dart';
import 'package:geooptima_app/pages/otp-verification.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
            
            // Be a Optima text
            Positioned(
              left: 19 * widthRatio,
              top: 195 * heightRatio,
              child: SizedBox(
                width: 269 * widthRatio,
                height: 156 * heightRatio,
                child: Text(
                  'Be a              Optima',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 50 * widthRatio,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            
            // TextField container
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
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
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
                  ),
                ),
              ),
            ),
            
            // Google sign-in button container
            Positioned(
              left: 27 * widthRatio,
              top: 760 * heightRatio,
              child: GestureDetector(
                onTap: () {
  if (_phoneController.text.isNotEmpty) {
    debugPrint('Phone number submitted: ${_phoneController.text}');
    // Navigate to OTP verification screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OtpVerificationScreen()),
    );
  }
},
                child: Container(
                  width: 347 * widthRatio,
                  height: 67 * heightRatio,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 3 * widthRatio),
                      borderRadius: BorderRadius.circular(30 * widthRatio),
                    ),
                  ),
                ),
              ),
            ),
            
            // Google sign-in text
            Positioned(
              left: 57 * widthRatio,
              top: 782 * heightRatio,
              child: Text(
                'Sign in with Google',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 20 * widthRatio,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Submit button container
            Positioned(
              left: 264 * widthRatio,
              top: 601 * heightRatio,
              child: GestureDetector(
                onTap: () {
                  // Process phone number submission
                  if (_phoneController.text.isNotEmpty) {
                    debugPrint('Phone number submitted: ${_phoneController.text}');
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
            
            // Enter your number text
            Positioned(
              left: 57 * widthRatio,
              top: 499 * heightRatio,
              child: Text(
                'Enter your number',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 20 * widthRatio,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Submit text
            Positioned(
              left: 281 * widthRatio,
              top: 615 * heightRatio,
              child: Text(
                'Submit',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 20 * widthRatio,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Register your self text
            Positioned(
              left: 27 * widthRatio,
              top: 437 * heightRatio,
              child: Text(
                'Register your self',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 20 * widthRatio,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Google logo
            Positioned(
              left: 275 * widthRatio,
              top: 758 * heightRatio,
              child: Container(
                width: 70 * widthRatio,
                height: 70 * heightRatio,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/google_logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Image.asset(
                  'assets/google_logo.png',
                  width: 70 * widthRatio,
                  height: 70 * heightRatio,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70 * widthRatio,
                      height: 70 * heightRatio,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.red,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}