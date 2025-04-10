import 'package:flutter/material.dart';
import 'package:geooptima_app/pages/register.dart';
import 'package:geooptima_app/pages/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const ResponsiveScreen(),
        '/register':
            (context) =>
                const RegisterScreen(),
        '/login':
            (context) =>
                const LoginScreen(), // Points to your RegisterScreen in register.dart
      },
    );
  }
}

class ResponsiveScreen extends StatefulWidget {
  const ResponsiveScreen({super.key});

  @override
  State<ResponsiveScreen> createState() => _ResponsiveScreenState();
}

class _ResponsiveScreenState extends State<ResponsiveScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/mainvideo.mp4');
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final widthRatio = screenWidth / 402;
    final heightRatio = screenHeight / 874;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Color(0xFFEAEFD9)),
        child: Stack(
          children: [
            // Background video
            Positioned(
              left: -260 * widthRatio,
              top: 283 * heightRatio,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8 * widthRatio),
                      child: SizedBox(
                        width: 844 * widthRatio,
                        height: 475 * heightRatio,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      width: 844 * widthRatio,
                      height: 475 * heightRatio,
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
            // Top black shape
            Positioned(
              left: 167 * widthRatio,
              top: -19 * heightRatio,
              child: Container(
                width: 395 * widthRatio,
                height: 179 * heightRatio,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20 * widthRatio),
                  ),
                ),
              ),
            ),
            // Rotated black shape
            Positioned(
              left: 302 * widthRatio,
              top: 145.60 * heightRatio,
              child: Transform(
                transform: Matrix4.identity()..rotateZ(-0.52),
                child: Container(
                  width: 375.21 * widthRatio,
                  height: 178.88 * heightRatio,
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20 * widthRatio),
                        bottomLeft: Radius.circular(20 * widthRatio),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom black shape
            Positioned(
              left: -229 * widthRatio,
              top: 751 * heightRatio,
              child: Container(
                width: 482 * widthRatio,
                height: 179 * heightRatio,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20 * widthRatio),
                  ),
                ),
              ),
            ),
            // Bottom rotated shape
            Positioned(
              left: -312 * widthRatio,
              top: 783.60 * heightRatio,
              child: Transform(
                transform: Matrix4.identity()..rotateZ(-0.52),
                child: Container(
                  width: 375.21 * widthRatio,
                  height: 178.88 * heightRatio,
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20 * widthRatio),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Get Started button with navigation
            Positioned(
              left: 218 * widthRatio,
              top: 655 * heightRatio,
              child: GestureDetector(
                onTapDown:
                    (_) => print('Tap down detected'), // Debug when tap starts
                onTapUp: (_) => print('Tap up detected'), // Debug when tap ends
                onTap: () {
                  print('Get Started tapped'); // Confirm tap completion
                  Navigator.pushNamed(context, '/register')
                      .then((_) {
                        print('Navigation to register completed');
                      })
                      .catchError((error) {
                        print('Navigation error: $error');
                      });
                },
                child: Container(
                  width: 167 * widthRatio,
                  height: 64 * heightRatio,
                  decoration: ShapeDecoration(
                    color: const Color(0x4CD9D9D9),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 3 * widthRatio),
                      borderRadius: BorderRadius.circular(20 * widthRatio),
                    ),
                  ),
                  child: Center(
                    // Added Center widget to ensure text is properly positioned
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 25 * widthRatio,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
              left: screenWidth * 0.028,
              top: screenHeight * -0.01,
              child: Text(
                'G',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: screenWidth * 0.16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Login text
            Positioned(
              left: 295 * widthRatio,
              top: 34 * heightRatio,
              child: Text(
                'Login',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 25 * widthRatio,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Login button container
            Positioned(
              left: 281 * widthRatio,
              top: 24 * heightRatio,
              child: GestureDetector(
                onTapDown:
                    (_) => print('Tap down detected'), // Debug when tap starts
                onTapUp: (_) => print('Tap up detected'), // Debug when tap ends
                onTap: () {
                  print('Get Started tapped'); // Confirm tap completion
                  Navigator.pushNamed(context, '/login')
                      .then((_) {
                        print('Navigation to register completed');
                      })
                      .catchError((error) {
                        print('Navigation error: $error');
                      });
                },
              child: Container(
                width: 100 * widthRatio,
                height: 50 * heightRatio,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2 * widthRatio,
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(20 * widthRatio),
                  ),
                ),
              ),
            ),
            ),
            // GeoOptima heading
            Positioned(
              left: 12 * widthRatio,
              top: 197 * heightRatio,
              child: Text(
                'GeoOptima',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 40 * widthRatio,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Subheading text
            Positioned(
              left: 12 * widthRatio,
              top: 251 * heightRatio,
              child: SizedBox(
                width: 269 * widthRatio,
                height: 156 * heightRatio,
                child: Text(
                  'Let\'s \nget you moving',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF808080),
                    fontSize: 20 * widthRatio,
                    fontWeight: FontWeight.w500,
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
