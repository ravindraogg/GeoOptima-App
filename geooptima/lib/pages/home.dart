import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'ola_map_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  MethodChannel? platform;
  LatLng _currentPosition = LatLng(12.9549, 77.5742);
  bool _isLoading = true;
  bool _isMapLoading = true;
  bool _isMapReady = false; // New flag to track map readiness
  List<Map<String, dynamic>> _recentVisits = [];
  String _olaMapsApiKey = '';
  bool _isMapError = false;
  String _errorMessage = '';
  bool _isFullScreen = false;
  bool _isLocationTracking = true;
  late AnimationController _animationController;
  Animation<double>? _fullScreenAnimation;

  final DraggableScrollableController _dragController =
      DraggableScrollableController();
  double _initialBottomSheetHeight = 0.25;
  double _minBottomSheetHeight = 0.25;
  double _maxBottomSheetHeight = 0.8;

  // Scale gesture states
  bool _isScaling = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fullScreenAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _loadApiKey();
    if (_olaMapsApiKey.isNotEmpty) {
      await _getUserLocation();
      await _loadRecentVisits();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadApiKey() async {
    try {
      await dotenv.load(fileName: "assets/.env");
      _olaMapsApiKey = dotenv.env['OLA_MAPS_API_KEY'] ?? '';
      if (_olaMapsApiKey.isEmpty) {
        throw Exception('OLA_MAPS_API_KEY not found in .env file.');
      }
      print('API Key loaded: ${_olaMapsApiKey.substring(0, 3)}...');
      await _validateApiKey();
    } catch (e) {
      setState(() {
        _isMapError = true;
        _errorMessage = 'Error loading API key: $e. Please check assets/.env.';
      });
      print('Error: $_errorMessage');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validateApiKey() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.olamaps.io/tiles/vector/v1/styles/default-light-standard/style.json?api_key=$_olaMapsApiKey',
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('Invalid API key (Status ${response.statusCode}).');
      }
    } catch (e) {
      setState(() {
        _isMapError = true;
        _errorMessage = 'Failed to validate API key: $e';
      });
      print('Error: $_errorMessage');
    }
  }

  Future<void> _moveCamera(LatLng position, [double zoom = 15.0]) async {
    if (platform == null || !_isMapReady) {
      print('Map not ready yet, retrying after delay');
      await Future.delayed(const Duration(milliseconds: 500));
      return _moveCamera(position, zoom); // Retry
    }
    try {
      setState(() {
        _isMapLoading = true;
      });
      await platform!.invokeMethod('moveCamera', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'zoom': zoom,
      });
      setState(() {
        _isMapLoading = false;
      });
    } on PlatformException catch (e) {
      print('Error moving camera: ${e.message}');
      setState(() {
        _isMapLoading = false;
      });
    }
  }

  Future<void> _addMarker(LatLng position, String id) async {
    if (platform == null || !_isMapReady) {
      print('Map not ready yet, skipping marker addition');
      return;
    }
    try {
      await platform!.invokeMethod('addMarker', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'id': id,
      });
    } on PlatformException catch (e) {
      print('Error adding marker: ${e.message}');
    }
  }

  Future<void> _clearAllMarkers() async {
    if (platform == null || !_isMapReady) {
      print('Map not ready yet, skipping clear markers');
      return;
    }
    try {
      await platform!.invokeMethod('clearMarkers');
    } on PlatformException catch (e) {
      print('Error clearing markers: ${e.message}');
    }
  }

 Future<void> _addCustomLocationMarker(LatLng position) async {
  if (platform == null || !_isMapReady) {
    print('Cannot add blue dot: platform=${platform != null}, isMapReady=$_isMapReady');
    return;
  }
  try {
    await platform!.invokeMethod('addCustomMarker', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'id': 'current_location',
      'iconType': 'blue_dot',
      'size': 48.0,
    });
    print('Blue dot added at ${position.latitude}, ${position.longitude}');
  } on PlatformException catch (e) {
    print('Error adding blue dot: ${e.message}');
  }
}

Future<void> _getUserLocation() async {
  setState(() {
    _isMapLoading = true;
  });
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services disabled');
      _showLocationServiceDisabledMessage();
      await _tryUseLastKnownPosition();
      return;
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        _showLocationPermissionDeniedMessage();
        await _tryUseLastKnownPosition();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission permanently denied');
      _showLocationPermissionPermanentlyDeniedMessage();
      await _tryUseLastKnownPosition();
      return;
    }

    // Fetch current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10), // Increased timeout
    );

    print('Location fetched: ${position.latitude}, ${position.longitude}');
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isMapLoading = false;
    });

    // Update map with retries
    await _updateMapWithRetries();
  } catch (e) {
    print('Error getting location: $e');
    setState(() {
      _isMapLoading = false;
    });
    await _tryUseLastKnownPosition();
  }
}

Future<void> _updateMapWithRetries({int maxRetries = 3, int delayMs = 500}) async {
  int attempts = 0;
  while (attempts < maxRetries && !_isMapReady) {
    print('Map not ready, retrying in ${delayMs}ms (attempt ${attempts + 1}/$maxRetries)');
    await Future.delayed(Duration(milliseconds: delayMs));
    attempts++;
  }

  if (_isMapReady) {
    print('Map ready, updating camera and markers');
    await _moveCamera(_currentPosition);
    await _clearAllMarkers();
    if (_isLocationTracking) {
      await _addCustomLocationMarker(_currentPosition);
    }
  } else {
    print('Map still not ready after $maxRetries retries');
  }
}
  void _showLocationServiceDisabledMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Location services are disabled. Using default location.',
        ),
        action: SnackBarAction(
          label: 'Enable',
          onPressed: () => Geolocator.openLocationSettings(),
        ),
      ),
    );
    setState(() {
      _isMapLoading = false;
    });
  }

  void _showLocationPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permission denied. Using default location.'),
      ),
    );
    setState(() {
      _isMapLoading = false;
    });
  }

  void _showLocationPermissionPermanentlyDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Location permission permanently denied. Using default location.',
        ),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => Geolocator.openAppSettings(),
        ),
      ),
    );
    setState(() {
      _isMapLoading = false;
    });
  }

  Future<void> _tryUseLastKnownPosition() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        if (_isMapReady) {
          await _moveCamera(_currentPosition);
          await _clearAllMarkers();
          await _addMarker(_currentPosition, 'current');
          if (_isLocationTracking) {
            await _addCustomLocationMarker(_currentPosition);
          }
        }
      }
    } catch (e) {
      print('Error getting last known position: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isMapLoading = false;
      });
    }
  }

  Future<void> _loadRecentVisits() async {
    final List<Map<String, dynamic>> predefinedVisits = [
      {
        'name': 'Centro Médico Nacional',
        'location': LatLng(19.406397, -99.164989),
      },
      {'name': 'ISKCON Bangalore', 'location': LatLng(13.0108, 77.5511)},
      {'name': 'Central Park', 'location': LatLng(40.7812, -73.9665)},
    ];

    List<Map<String, dynamic>> visits = [];

    for (var visit in predefinedVisits) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://api.olamaps.io/places/v1/nearbysearch'
            '?api_key=$_olaMapsApiKey'
            '&location=${visit['location'].latitude},${visit['location'].longitude}'
            '&radius=1000',
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['predictions'] != null && data['predictions'].isNotEmpty) {
            final result = data['predictions'][0];
            String imageUrl =
                'https://via.placeholder.com/300x180.png?text=${Uri.encodeComponent(result['description'] ?? visit['name'])}';

            visits.add({
              'name': result['description'] ?? visit['name'],
              'image': imageUrl,
              'location': visit['location'],
              'address': result['description'] ?? 'Unknown Address',
              'rating': 4.5 + (visits.length * 0.3),
            });

            if (!_isFullScreen && _isMapReady) {
              await _addMarker(visit['location'], 'visit_${visits.length}');
            }
          }
        } else {
          print(
            'Failed to fetch visit ${visit['name']}: ${response.statusCode}',
          );
          visits.add({
            'name': visit['name'],
            'image': 'https://via.placeholder.com/300x180.png?text=Error',
            'location': visit['location'],
            'address': 'Failed to load address',
            'rating': 4.0,
          });
        }
      } catch (e) {
        print('Error fetching visit ${visit['name']}: $e');
        visits.add({
          'name': visit['name'],
          'image': 'https://via.placeholder.com/300x180.png?text=Error',
          'location': visit['location'],
          'address': 'Failed to load address',
          'rating': 4.0,
        });
      }
    }

    setState(() {
      _recentVisits = visits;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        _animationController.forward();
        _dragController.animateTo(
          _minBottomSheetHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _animationController.reverse();
        _dragController.animateTo(
          _initialBottomSheetHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });

    if (_isMapReady) {
      _getUserLocation();
    }
  }

  void _toggleLocationTracking() {
    setState(() {
      _isLocationTracking = !_isLocationTracking;
    });

    if (_isLocationTracking && _isMapReady) {
      _getUserLocation();
    } else {
      _clearAllMarkers();
    }
  }

  Future<void> _retryLoadApiKey() async {
    setState(() {
      _isMapError = false;
      _errorMessage = '';
      _isLoading = true;
      _isMapLoading = true;
    });
    await _loadApiKey();
    if (!_isMapError) {
      await _getUserLocation();
      await _loadRecentVisits();
    }
  }

  void _handleMapError(String error) {
    setState(() {
      _isMapError = true;
      _errorMessage = 'Map error: $error';
      _isMapLoading = false;
    });
  }

  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('authToken');
    await prefs.remove('phoneNumber');
    debugPrint('Login state cleared');
  }

  Future<bool> _onWillPop() async {
    if (_isFullScreen) {
      _toggleFullScreen();
      return false;
    }

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit App',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Do you want to exit the app or go back to login/register?',
              style: GoogleFonts.montserrat(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.montserrat(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _clearLoginState();
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Logout',
                  style: GoogleFonts.montserrat(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_fullScreenAnimation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                // Map container with improved gesture handling
                RawGestureDetector(
                  gestures: {
                    ScaleGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                      () => ScaleGestureRecognizer(),
                      (ScaleGestureRecognizer instance) {
                        instance
                          ..onStart = (details) {
                            _isScaling = true;
                          }
                          ..onUpdate = (details) {
                            if (_isScaling &&
                                details.scale > 1.1 &&
                                !_isFullScreen &&
                                _olaMapsApiKey.isNotEmpty) {
                              _toggleFullScreen();
                              _isScaling = false;
                            }
                          }
                          ..onEnd = (details) {
                            _isScaling = false;
                          };
                      },
                    ),
                    TapGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                      () => TapGestureRecognizer(),
                      (TapGestureRecognizer instance) {
                        instance
                          ..onTap = () {
                            if (!_isFullScreen && _olaMapsApiKey.isNotEmpty) {
                              _toggleFullScreen();
                            }
                          };
                      },
                    ),
                    DoubleTapGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
                      () => DoubleTapGestureRecognizer(),
                      (DoubleTapGestureRecognizer instance) {
                        instance
                          ..onDoubleTap = () {
                            if (_isFullScreen) {
                              _toggleFullScreen();
                            }
                          };
                      },
                    ),
                  },
                  child: ScaleTransition(
                    scale: _fullScreenAnimation!,
                    child: _olaMapsApiKey.isEmpty
                        ? Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text(
                                'Map unavailable. Please provide an Ola Maps API key.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : OlaMapView(
                            apiKey: _olaMapsApiKey,
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition,
                              zoom: 15.0,
                            ),
                            onMapCreated: (MethodChannel channel) {
                              setState(() {
                                platform = channel;
                              });
                              channel.setMethodCallHandler((call) async {
                                if (call.method == 'onError') {
                                  _handleMapError(call.arguments as String);
                                } else if (call.method == 'onMapLoaded') {
                                  setState(() {
                                    _isMapReady = true;
                                    _isMapLoading = false;
                                  });
                                  _moveCamera(_currentPosition);
                                  _addMarker(_currentPosition, 'current');
                                  if (_isLocationTracking) {
                                    _addCustomLocationMarker(_currentPosition);
                                  }
                                }
                                return null;
                              });
                            },
                          ),
                  ),
                ),

                // Regular view UI elements
                if (!_isFullScreen && _olaMapsApiKey.isNotEmpty) ...[
                  _buildSidebar(),
                  _buildSearchBar(),
                  _buildCategoryFilters(),
                  _buildDraggableRecentVisits(),
                  _buildLocationButton(),
                ],

                // Full screen view UI elements
                if (_isFullScreen && _olaMapsApiKey.isNotEmpty) ...[
                  // Back button
                  Positioned(
                    left: 15,
                    top: 15,
                    child: GestureDetector(
                      onTap: _toggleFullScreen,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'G',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Search bar
                  Positioned(
                    left: 70,
                    top: 15,
                    right: 15,
                    child: Container(
                      height: 42,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1.5),
                          borderRadius: BorderRadius.circular(21),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Location button
                  Positioned(
                    right: 15,
                    bottom: 145,
                    child: Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      color: Colors.black,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _getUserLocation,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const ShapeDecoration(
                            color: Colors.black,
                            shape: CircleBorder(),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Location tracking toggle
                  Positioned(
                    right: 15,
                    bottom: 85,
                    child: Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      color: _isLocationTracking ? Colors.blue : Colors.grey,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _toggleLocationTracking,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: ShapeDecoration(
                            color:
                                _isLocationTracking ? Colors.blue : Colors.grey,
                            shape: const CircleBorder(),
                          ),
                          child: Icon(
                            _isLocationTracking
                                ? Icons.gps_fixed
                                : Icons.gps_not_fixed,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Zoom controls
                  Positioned(
                    right: 15,
                    bottom: 25,
                    child: Column(
                      children: [
                        Material(
                          elevation: 4,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              if (_isMapReady) {
                                await _moveCamera(_currentPosition, 16.0);
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const ShapeDecoration(
                                color: Colors.white,
                                shape: CircleBorder(),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          elevation: 4,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              if (_isMapReady) {
                                await _moveCamera(_currentPosition, 14.0);
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const ShapeDecoration(
                                color: Colors.white,
                                shape: CircleBorder(),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Loading and error indicators
                if (_isMapLoading)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading map...',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_isLoading && !_isMapLoading)
                  const Center(child: CircularProgressIndicator()),

                if (_isMapError)
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
                          const Icon(
                            Icons.error_outline,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Map Error',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _retryLoadApiKey,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () =>
                                    setState(() => _isMapError = false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
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
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 60),
           _sidebarButton(Icons.person, () {
  Navigator.pushNamed(context, '/profile');
}),

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
          color: const Color(0x33D9D9D9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
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
              offset: const Offset(0, 2),
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
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.search, color: Colors.black, size: 25),
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
            offset: const Offset(0, 1),
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
              textStyle: const TextStyle(
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Recent Visits',
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {},
                      ),
                    ],
                  ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _recentVisits.length,
                        itemBuilder: (context, index) {
                          final visit = _recentVisits[index];
                          return GestureDetector(
                            onTap: () => _moveCamera(visit['location']),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(visit['image']),
                                        fit: BoxFit.cover,
                                        onError: (_, __) => const AssetImage(
                                          'assets/placeholder.jpg',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                visit['name'],
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${visit['rating']}',
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          visit['address'],
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _actionButton(
                                              Icons.directions,
                                              'Directions',
                                            ),
                                            const SizedBox(width: 12),
                                            _actionButton(
                                              Icons.info_outline,
                                              'Details',
                                            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(
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
      bottom:
          MediaQuery.of(context).size.height * _initialBottomSheetHeight + 20,
      child: Material(
        elevation: 4,
        shape: const CircleBorder(),
        color: Colors.black,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _getUserLocation,
          child: Container(
            width: 60,
            height: 60,
            decoration: const ShapeDecoration(
              color: Colors.black,
              shape: CircleBorder(),
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}