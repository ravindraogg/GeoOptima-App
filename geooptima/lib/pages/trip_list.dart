import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripListPage extends StatelessWidget {
  const TripListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double widthRatio = screenWidth / 375; // Base ratio for responsive design
    final double statusBarHeight = MediaQuery.of(context).padding.top; // Height of status bar

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight - statusBarHeight, // Adjust height to exclude status bar
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // Polygon image (top-left "G" background)
              Positioned(
                left: -4 * widthRatio,
                top: 0,
                child: Image.asset(
                  'assets/poly2.png',
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading poly2.png asset, creating placeholder');
                    return Container(
                      width: screenWidth * 0.18,
                      height: screenWidth * 0.18,
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // G text as back button
              Positioned(
                left: 0,
                top: -8 * widthRatio,
                child: GestureDetector(
                  onTap: () {
                    debugPrint('Back button tapped');
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8 * widthRatio),
                    child: Text(
                      'G',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: screenWidth * 0.14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              // Trip List Title
              Positioned(
                left: screenWidth * 0.16,
                top: 8 * widthRatio,
                child: Text(
                  'Trip List',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Trip cards container
              Positioned(
                top: screenHeight * 0.08,
                left: 0,
                right: 0,
                bottom: screenHeight * 0.14,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Trip card 1 - Left aligned (index 1)
                      _buildTripCard(
                        context: context,
                        index: 1,
                        screenWidth: screenWidth,
                        widthRatio: widthRatio,
                        hasImage: true,
                        from: 'Home',
                        to: 'BIT',
                        numJoined: 3,
                      ),
                      // Trip card 2 - Right aligned (index 2)
                      _buildTripCard(
                        context: context,
                        index: 2,
                        screenWidth: screenWidth,
                        widthRatio: widthRatio,
                        hasImage: true,
                        from: 'Home',
                        to: 'BIT',
                        numJoined: 2,
                      ),
                      // Trip card 3 - Left aligned (index 3)
                      _buildTripCard(
                        context: context,
                        index: 3,
                        screenWidth: screenWidth,
                        widthRatio: widthRatio,
                        hasImage: true,
                        from: 'Home',
                        to: 'BIT',
                        numJoined: 1,
                      ),
                    ],
                  ),
                ),
              ),
              // Add trip button
              Positioned(
                bottom: screenHeight * 0.14,
                right: screenWidth * 0.04,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/add-trip');
                  },
                  child: Container(
                    width: screenWidth * 0.35,
                    height: screenHeight * 0.05,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25 * widthRatio),
                    ),
                    child: Center(
                      child: Text(
                        'Add trip',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Navigation Bar with curved top
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * 0.08,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavBarItem(
                        context: context,
                        icon: Icons.home,
                        label: 'Home',
                        route: '/home',
                        screenWidth: screenWidth,
                        widthRatio: widthRatio,
                      ),
                      _buildNavBarItem(
                        context: context,
                        icon: Icons.map,
                        label: 'Route',
                        route: '/route',
                        screenWidth: screenWidth,
                        widthRatio: widthRatio,
                      ),
                      _buildNavBarItem(
                        context: context,
                        icon: Icons.format_list_bulleted,
                        label: 'Trip List',
                        route: '/trip-list',
                        isActive: true,
                        screenWidth: screenWidth,
                        widthRatio: widthRatio,
                      ),
                      _buildNavBarItem(
                        context: context,
                        icon: Icons.directions_car,
                        label: 'Your Vehicle',
                        route: '/vehicle',
                        screenWidth: screenWidth,
                        widthRatio: widthRatio,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard({
    required BuildContext context,
    required int index,
    required double screenWidth,
    required double widthRatio,
    bool hasImage = true,
    required String from,
    required String to,
    int numJoined = 0,
  }) {
    bool isRightAligned = index % 2 == 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12 * widthRatio),
      child: Row(
        mainAxisAlignment: isRightAligned ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isRightAligned) ...[
            SizedBox(width: 6 * widthRatio),
            Container(
              width: 50 * widthRatio,
              height: 50 * widthRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/poly3.png',
                    width: 50 * widthRatio,
                    height: 50 * widthRatio,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading poly3.png asset for marker: $error');
                      return Container(color: Colors.black);
                    },
                  ),
                  Text(
                    index.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * widthRatio,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * widthRatio),
          ],
          Container(
            width: screenWidth * 0.65,
            height: 90 * widthRatio,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5 * widthRatio),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage)
                  Padding(
                    padding: EdgeInsets.all(6 * widthRatio),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8 * widthRatio),
                      child: Image.asset(
                        'assets/google_logo.png',
                        width: 60 * widthRatio,
                        height: 60 * widthRatio,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: $error');
                          return Container(
                            width: 60 * widthRatio,
                            height: 60 * widthRatio,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double contentWidth = constraints.maxWidth;

                      return Stack(
                        children: [
                          // Curved connector
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: contentWidth,
                            child: CustomPaint(
                              size: Size(contentWidth, 70 * widthRatio),
                              painter: SShapeConnectorPainter(widthRatio: widthRatio),
                            ),
                          ),
                          // Content layout
                          Padding(
                            padding: EdgeInsets.only(right: 6 * widthRatio),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // From address
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 3 * widthRatio, top: 6 * widthRatio, right: 3 * widthRatio),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6 * widthRatio,
                                        height: 6 * widthRatio,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 3 * widthRatio),
                                      Expanded(
                                        child: Text(
                                          'From: $from',
                                          style: TextStyle(
                                            fontSize: 11 * widthRatio,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // To address
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 3 * widthRatio, top: 25 * widthRatio, right: 3 * widthRatio),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6 * widthRatio,
                                        height: 6 * widthRatio,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 3 * widthRatio),
                                      Expanded(
                                        child: Text(
                                          'To: $to',
                                          style: TextStyle(
                                            fontSize: 11 * widthRatio,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Joined users section
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 3 * widthRatio, bottom: 3 * widthRatio),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Joined',
                                            style: TextStyle(fontSize: 9 * widthRatio),
                                          ),
                                          SizedBox(width: 6 * widthRatio),
                                          SizedBox(
                                            height: 16 * widthRatio,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: List.generate(
                                                numJoined,
                                                (index) => Padding(
                                                  padding: EdgeInsets.only(left: 2 * widthRatio),
                                                  child: CircleAvatar(
                                                    radius: 7 * widthRatio,
                                                    backgroundColor: Colors.grey[300],
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 9 * widthRatio,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isRightAligned) ...[
            SizedBox(width: 8 * widthRatio),
            Container(
              width: 50 * widthRatio,
              height: 50 * widthRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: 180 * 3.14159 / 180,
                    child: Image.asset(
                      'assets/poly3.png',
                      width: 50 * widthRatio,
                      height: 50 * widthRatio,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading poly3.png asset for marker: $error');
                        return Container(color: Colors.black);
                      },
                    ),
                  ),
                  Text(
                    index.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * widthRatio,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6 * widthRatio),
          ],
        ],
      ),
    );
  }

  Widget _buildNavBarItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required double screenWidth,
    required double widthRatio,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
            size: screenWidth * 0.06,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: screenWidth * 0.028,
            ),
          ),
        ],
      ),
    );
  }
}

class SShapeConnectorPainter extends CustomPainter {
  final double widthRatio;

  SShapeConnectorPainter({required this.widthRatio});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * widthRatio;

    final startX = 0.0;
    final startY = 6 * widthRatio; // Align with "From" dot
    final endX = 0.0;
    final endY = size.height - 6 * widthRatio; // Align with "To" dot
    final controlX = size.width * 0.85; // Adjusted for responsive curve
    final controlY = (startY + endY) / 2;

    Path path = Path();
    path.moveTo(startX, startY);
    path.quadraticBezierTo(
      controlX,
      controlY,
      endX,
      endY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}