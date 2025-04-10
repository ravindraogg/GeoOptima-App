import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (index) => FocusNode());
  bool _isLoading = false; // Added loading state

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) controller.dispose();
    for (var focusNode in _otpFocusNodes) focusNode.dispose();
    super.dispose();
  }

  String get completeOtp => _otpControllers.map((controller) => controller.text).join();

  Future<void> _verifyOtp() async {
    if (completeOtp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter complete OTP code')));
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.122.137:5000/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': widget.phoneNumber,
          'otp': completeOtp,
          'otpExpires': DateTime.now().toIso8601String(), // Temporary dummy value
        }),
      );

      setState(() {
        _isLoading = false; // Stop loading
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        debugPrint('Token: ${data['token']}');
        // Navigate to next screen
        // Example: Navigator.pushReplacementNamed(context, '/home');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Verification failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to verify OTP: $e')));
      debugPrint('Verification error details: $e');
      debugPrint('Response body or exception: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final widthRatio = screenWidth / 402;
    final heightRatio = screenHeight / 874;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: screenWidth,
          height: screenHeight,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
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
              Positioned(
                left: screenWidth * 0.00,
                top: screenHeight * -0.02,
                child: GestureDetector(
                  onTap: () {
                    debugPrint('Back button tapped');
                    Navigator.pop(context);
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
                            if (value.length == 1 && index < 3) {
                              FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
                            }
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
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
                  onTap: _isLoading ? null : _verifyOtp, // Disable tap when loading
                  child: Container(
                    width: 110 * widthRatio,
                    height: 51 * heightRatio,
                    decoration: ShapeDecoration(
                      color: const Color(0x4CD9D9D9), // Match RegisterScreen style
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 3 * widthRatio),
                        borderRadius: BorderRadius.circular(20 * widthRatio), // Match RegisterScreen
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
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
              Positioned(
                left: 27 * widthRatio,
                top: 615 * heightRatio,
                child: GestureDetector(
                  onTap: () {
                    debugPrint('Resend code requested');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP code resent')),
                    );
                  },
                  child: Text(
                    'Resend code',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
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
      ),
    );
  }
}