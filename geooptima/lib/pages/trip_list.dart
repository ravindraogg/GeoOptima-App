import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripListPage extends StatelessWidget {
  const TripListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double widthRatio = screenWidth / 375; // Base ratio for responsive design

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // Polygon image (top-left "G" background)
            Positioned(
              left: -4,
              top: 0,
              child: Image.asset(
                'assets/poly2.png',
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading poly2.png asset, creating placeholder');
                  return Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // G text as back button
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
            
            // Trip List Title
            Positioned(
              left: screenWidth * 0.18,
              top: screenHeight * 0.03,
              child: Text(
                'Trip List',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Trip cards container
            Positioned(
              top: screenHeight * 0.1,
              left: 0,
              right: 0,
              bottom: screenHeight * 0.1,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Trip card 1 - Left aligned (index 1)
                    _buildTripCard(
                      context: context,
                      index: 1,
                      screenWidth: screenWidth,
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
              bottom: screenHeight * 0.12,
              right: screenWidth * 0.05,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/add-trip');
                },
                child: Container(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'Add trip',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: screenWidth * 0.05,
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
                height: screenHeight * 0.09,
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
                    ),
                    _buildNavBarItem(
                      context: context, 
                      icon: Icons.map, 
                      label: 'Route',
                      route: '/route',
                      screenWidth: screenWidth,
                    ),
                    _buildNavBarItem(
                      context: context, 
                      icon: Icons.format_list_bulleted, 
                      label: 'Trip List',
                      route: '/trip-list',
                      isActive: true,
                      screenWidth: screenWidth,
                    ),
                    _buildNavBarItem(
                      context: context, 
                      icon: Icons.directions_car, 
                      label: 'Your Vehicle',
                      route: '/vehicle',
                      screenWidth: screenWidth,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildTripCard({
  required BuildContext context,
  required int index,
  required double screenWidth,
  bool hasImage = true,
  required String from,
  required String to,
  int numJoined = 0,
}) {
  bool isRightAligned = index % 2 == 0;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Row(
      mainAxisAlignment: isRightAligned ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isRightAligned) ...[
          SizedBox(width: 8),
          Container(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/poly3.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading poly3.png asset for marker: $error');
                    return Container(color: Colors.black);
                  },
                ),
                Text(
                  index.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
        Container(
          width: screenWidth * 0.7,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
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
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/google_logo.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading image: $error');
                        return Container(
                          width: 70,
                          height: 70,
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
                    // Calculate available space for content
                    double contentWidth = constraints.maxWidth;
                    
                    return Stack(
                      children: [
                        // Curved connector positioned to match the design
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: contentWidth, // Allow full width for the outward curve
                          child: CustomPaint(
                            size: Size(contentWidth, 80),
                            painter: SShapeConnectorPainter(),
                          ),
                        ),
                        
                        // Content layout with better positioning
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // From address - with black dot at the start of the curve
                              Padding(
                                padding: const EdgeInsets.only(left: 4, top: 8, right: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'From: $from',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // To address - with black dot at the end of the curve
                              Padding(
                                padding: const EdgeInsets.only(left: 4, top: 30, right: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'To: $to',
                                        style: const TextStyle(
                                          fontSize: 12,
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
                                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Joined',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          height: 18,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(
                                              numJoined,
                                              (index) => Padding(
                                                padding: const EdgeInsets.only(left: 2),
                                                child: CircleAvatar(
                                                  radius: 8,
                                                  backgroundColor: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 10,
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
          const SizedBox(width: 10),
          Container(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: 180 * 3.14159 / 180,
                  child: Image.asset(
                    'assets/poly3.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading poly3.png asset for marker: $error');
                      return Container(color: Colors.black);
                    },
                  ),
                ),
                Text(
                  index.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
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
            size: screenWidth * 0.07,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: screenWidth * 0.03,
            ),
          ),
        ],
      ),
    );
  }
}
class SShapeConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Calculate coordinates for a curve that bulges outward to the right
    final startX = 0.0; // Start at the black dot for "From"
    final startY = 8.0; // Align with the "From" dot
    
    final endX = 0.0;   // End at the black dot for "To"
    final endY = size.height - 8.0; // Align with the "To" dot
    
    // Control point far to the right to create the outward curve
    final controlX = size.width * 0.9; // Push control point far to the right
    final controlY = (startY + endY) / 2; // Middle point between start and end
    
    Path path = Path();
    path.moveTo(startX, startY); // Start at "From" dot
    
    // Use quadraticBezierTo for a simpler outward curve like in the image
    path.quadraticBezierTo(
      controlX, controlY, // Control point far to the right
      endX, endY          // End at "To" dot
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}