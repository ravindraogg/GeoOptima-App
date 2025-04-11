import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng _currentPosition = LatLng(12.9549, 77.5742); // Default position (Bangalore)
  final MapController _mapController = MapController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentVisits = [];
  String _tomtomApiKey = '';
  bool _isMapError = false;
  String _errorMessage = '';
  
  // For draggable bottom sheet
  final DraggableScrollableController _dragController = DraggableScrollableController();
  double _initialBottomSheetHeight = 0.25; // 25% of screen height
  double _minBottomSheetHeight = 0.25;
  double _maxBottomSheetHeight = 0.8; // 80% of screen height

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadApiKey();
    await _getUserLocation();
    _loadRecentVisits();
  }

  Future<void> _loadApiKey() async {
    try {
      // Make sure dotenv is loaded before trying to access env variables
      await dotenv.load(fileName: "assets/.env");
      _tomtomApiKey = dotenv.env['TOMTOM_API_KEY'] ?? '';
      
      if (_tomtomApiKey.isEmpty) {
        setState(() {
          _isMapError = true;
          _errorMessage = 'TomTom API key not found. Using OpenStreetMap as fallback.';
        });
        print('Warning: $_errorMessage');
      } else {
        print('API Key loaded successfully: ${_tomtomApiKey.substring(0, 3)}...');
      }
    } catch (e) {
      setState(() {
        _isMapError = true;
        _errorMessage = 'Failed to load .env file. Using OpenStreetMap as fallback.';
      });
      print('Warning: $_errorMessage');
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDisabledMessage();
        _tryUseLastKnownPosition();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDeniedMessage();
          _tryUseLastKnownPosition();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionPermanentlyDeniedMessage();
        _tryUseLastKnownPosition();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      
      _mapController.move(_currentPosition, 15);
    } catch (e) {
      print('Error getting location: $e');
      _tryUseLastKnownPosition();
    }
  }

  void _showLocationServiceDisabledMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location services are disabled. Using default location.'),
        action: SnackBarAction(
          label: 'Enable',
          onPressed: () => Geolocator.openLocationSettings(),
        ),
      ),
    );
  }

  void _showLocationPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location permission denied. Using default location.'),
      ),
    );
  }

  void _showLocationPermissionPermanentlyDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location permission permanently denied. Using default location.'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => Geolocator.openAppSettings(),
        ),
      ),
    );
  }

  Future<void> _tryUseLastKnownPosition() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController.move(_currentPosition, 15);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentVisits() async {
    // In a real app, you would load these from local storage or an API
    // This is mock data for demonstration
    setState(() {
      _recentVisits = [
        {
          'name': 'Centro Médico Nacional',
          'image': 'assets/images/centro_medico.jpg',
          'location': LatLng(19.406397, -99.164989),
          'address': '123 Main St, Mexico City, Mexico',
          'rating': 4.5,
        },
        {
          'name': 'ISKCON Bangalore',
          'image': 'assets/images/iskcon.jpg',
          'location': LatLng(13.0108, 77.5511),
          'address': 'Hare Krishna Hill, Bangalore, India',
          'rating': 4.8,
        },
        {
          'name': 'Central Park',
          'image': 'assets/images/central_park.jpg',
          'location': LatLng(40.7812, -73.9665),
          'address': 'New York, NY, USA',
          'rating': 4.9,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // Map
              _buildMap(),
              
              // Left sidebar
              _buildSidebar(),
              
              // Search bar
              _buildSearchBar(),
              
              // Category filters
              _buildCategoryFilters(),
              
              // Bottom Recent Visits (Draggable)
              _buildDraggableRecentVisits(),
              
              // Location button
              _buildLocationButton(),

              // Loading indicator
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),

              // Error message if map fails to load
              if (_isMapError && _tomtomApiKey.isEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Map API Notice',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          style: GoogleFonts.montserrat(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isMapError = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Dismiss',
                            style: GoogleFonts.montserrat(),
                          ),
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

  Widget _buildMap() {
    // Fall back to OpenStreetMap if TomTom API key is missing
    final bool useFallbackMap = _tomtomApiKey.isEmpty;
    final String urlTemplate = useFallbackMap
        ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
        : 'https://api.tomtom.com/map/1/tile/basic/{z}/{x}/{y}.png?key={apiKey}';
    
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentPosition,
        zoom: 15,
        maxZoom: 18,
        minZoom: 3,
        interactiveFlags: InteractiveFlag.all,
        onMapEvent: (MapEvent event) {
          if (event is MapEventMoveEnd) {
            print('Map moved to: ${event.camera.center}, zoom: ${event.camera.zoom}');
          }
        },
      ),
      children: [
       TileLayer(
  urlTemplate: urlTemplate,
  additionalOptions: useFallbackMap ? {} : {'apiKey': _tomtomApiKey},
  userAgentPackageName: 'com.example.app',
  tileProvider: NetworkTileProvider(),
  // Just remove the errorImage parameter or use an asset
  // errorImage: AssetImage('assets/images/map_error.png'),
  evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
  errorTileCallback: (tile, error, stackTrace) {
    print('Error loading tile: $error');
    if (error.toString().contains('No host specified in URI')) {
      // This is expected for the initial load, don't show an error
      return;
    }
    
    // Only show the error if it's not the "empty API key" error we already handle
    if (!_isMapError && _tomtomApiKey.isNotEmpty) {
      setState(() {
        _isMapError = true;
        _errorMessage = 'Failed to load map tiles. Check your internet connection.';
      });
    }
  },
),
        MarkerLayer(
          markers: [
            Marker(
              point: _currentPosition,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),
            ),
            // Add markers for recent visits
            ..._recentVisits.map((visit) => Marker(
              point: visit['location'],
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.place,
                    color: Colors.blue,
                    size: 25,
                  ),
                ),
              ),
            )).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 60,
        decoration: const ShapeDecoration(
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Text(
              'G',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 60), // Increased to move icons down
            _sidebarButton(Icons.person, () {}),
            const SizedBox(height: 25),
            _sidebarButton(Icons.grid_view, () {}),
            const SizedBox(height: 25),
            _sidebarButton(Icons.directions_car, () {}),
            const SizedBox(height: 25),
            _sidebarButton(Icons.music_note, () {}),
            const Spacer(),
            _sidebarButton(Icons.settings, () {}),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _sidebarButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Color(0x33D9D9D9),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      left: 75,
      top: 17,
      right: 20,
      child: Container(
        height: 48,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              'Search',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.search,
                color: Colors.black,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Positioned(
      left: 75,
      top: 80,
      right: 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _categoryButton('Fuel', Icons.local_gas_station),
            const SizedBox(width: 11),
            _categoryButton('Restaurant', Icons.restaurant),
            const SizedBox(width: 11),
            _categoryButton('Groceries', Icons.shopping_cart),
            const SizedBox(width: 11),
            _categoryButton('Hotels', Icons.hotel),
            const SizedBox(width: 11),
            _categoryButton('ATMs', Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _categoryButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.5, color: Colors.black87),
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableRecentVisits() {
    return DraggableScrollableSheet(
      initialChildSize: _initialBottomSheetHeight,
      minChildSize: _minBottomSheetHeight,
      maxChildSize: _maxBottomSheetHeight,
      controller: _dragController,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Visits',
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_horiz),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _recentVisits.isEmpty
                    ? Center(
                        child: Text(
                          'No recent visits',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _recentVisits.length,
                        itemBuilder: (context, index) {
                          final visit = _recentVisits[index];
                          return GestureDetector(
                            onTap: () {
                              _mapController.move(visit['location'], 15);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(visit['image']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Details
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              visit['name'],
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 18),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${visit['rating']}',
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          visit['address'],
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _actionButton(Icons.directions, 'Directions'),
                                            SizedBox(width: 12),
                                            _actionButton(Icons.info_outline, 'Details'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return Positioned(
      right: 20,
      bottom: MediaQuery.of(context).size.height * _initialBottomSheetHeight + 20,
      child: Material(
        elevation: 4,
        shape: CircleBorder(),
        color: Colors.black,
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () {
            _getUserLocation();
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: const ShapeDecoration(
              color: Colors.black,
              shape: CircleBorder(),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}