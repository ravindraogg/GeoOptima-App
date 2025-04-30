import 'package:flutter/material.dart';
import 'package:geooptima/pages/home.dart';
import 'package:geooptima/pages/profile_summary_screen.dart';
import 'package:geooptima/pages/register.dart';
import 'package:geooptima/pages/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await checkLoginStatus();
  runApp(MyApp(isLoggedIn: isLoggedIn));

  try {
    await dotenv.load(fileName: "assets/.env");
    developer.log("Loaded .env successfully", name: 'Main');
  } catch (e) {
    developer.log("Error loading .env: $e", name: 'Main');
  }
}

Future<bool> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/home' : '/', // Redirect to home if logged in
      routes: {
        '/': (context) => const ResponsiveScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfileSummaryScreen(),
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

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      await Permission.location.request();
    }
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

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: screenWidth,
          height: screenHeight,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Color(0xFFEAEFD9)),
          child: Stack(
            children: [
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
              Positioned(
                left: 218 * widthRatio,
                top: 655 * heightRatio,
                child: GestureDetector(
                  onTapDown: (_) => print('Tap down detected'),
                  onTapUp: (_) => print('Tap up detected'),
                  onTap: () {
                    print('Get Started tapped');
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
              Positioned(
                left: 295 * widthRatio,
                top: 33 * heightRatio,
                child: Text(
                  'Login',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 25 * widthRatio,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 281 * widthRatio,
                top: 24 * heightRatio,
                child: GestureDetector(
                  onTapDown: (_) => print('Tap down detected'),
                  onTapUp: (_) => print('Tap up detected'),
                  onTap: () {
                    print('Get Started tapped');
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
      ),
    );
  }
}
