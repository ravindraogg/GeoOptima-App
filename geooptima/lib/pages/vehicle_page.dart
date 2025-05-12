import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'add_vehicle_page.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = false;
  int _currentIndex = 3; // Vehicle page index
  String _backendUrl = '';
  final _storage = const FlutterSecureStorage();

  final double widthRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _loadBackendUrl();
    _loadVehicles();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadBackendUrl() async {
    try {
      await dotenv.load(fileName: "assets/.env");
      if (mounted) {
        setState(() {
          _backendUrl = dotenv.env['BACKEND_URL'] ?? 'https://backend-codecrib-cja0h8fdepdbfkgx.canadacentral-01.azurewebsites.net';
        });
      }
      if (_backendUrl.isEmpty) {
        throw Exception('BACKEND_URL not found in .env file.');
      }
    } catch (e) {
      print('Backend URL load error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading backend URL: $e')),
        );
      }
    }
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> _loadVehicles() async {
    final token = await _getToken();
    if (token == null) {
      print('No JWT token found');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      print('Fetching vehicles from $_backendUrl/api/auth/vehicle with token: $token');
      final response = await http.get(
        Uri.parse('$_backendUrl/api/auth/vehicle'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Get vehicles response: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> vehicles = data['vehicles'] ?? [];

        if (vehicles.isEmpty) {
          print('No vehicles found in response');
          if (mounted) {
            setState(() {
              _vehicles = [];
            });
          }
          return;
        }

        if (mounted) {
          setState(() {
            _vehicles = vehicles.map((v) {
              String? base64Image = v['image'];
              Uint8List? imageBytes;
              if (base64Image != null && base64Image.isNotEmpty) {
                try {
                  imageBytes = base64Decode(base64Image);
                } catch (e) {
                  print('Error decoding Base64 image for vehicle ${v['name']}: $e');
                }
              }
              return {
                'name': v['name'],
                'model': v['model'],
                'mileage': v['mileage'],
                'fuelCapacity': v['fuelCapacity'],
                'vehicleType': v['vehicleType'],
                'registrationNumber': v['registrationNumber'],
                'sizeWeight': v['sizeWeight'],
                'fuelType': v['fuelType'],
                'isDefault': v['isDefault'],
                'image': imageBytes,
                'createdAt': v['createdAt'],
              };
            }).toList();
          });
        }
        print('Loaded ${_vehicles.length} vehicles');
      } else {
        throw Exception('Failed to load vehicles: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading vehicles: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
            Positioned(
              left: screenWidth * 0.00,
              top: screenHeight * -0.02,
              child: GestureDetector(
                onTap: () {
                  print('Back button tapped');
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 60), // Space for "G" logo
                      Text(
                        'Your Vehicle',
                        style: GoogleFonts.montserrat(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filter feature coming soon!')),
                            );
                          }
                        },
                        child: Text(
                          'Filter',
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _vehicles.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: Text(
                            'No vehicles added',
                            style: GoogleFonts.montserrat(
                              fontSize: screenWidth * 0.05,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.04, // Increased top padding to move cards down
                          ),
                          itemCount: _vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = _vehicles[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                width: 360, // Slightly increased width
                                height: 140, // Increased height to prevent overflow
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 2, color: Colors.black),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: vehicle['image'] != null
                                          ? Image.memory(
                                              vehicle['image'],
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Image error for vehicle ${vehicle['name']}: $error');
                                                return Icon(
                                                  Icons.directions_car,
                                                  size: 40,
                                                  color: Colors.grey[600],
                                                );
                                              },
                                            )
                                          : Icon(
                                              Icons.directions_car,
                                              size: 40,
                                              color: Colors.grey[600],
                                            ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              vehicle['name'] ?? 'Unnamed Vehicle',
                                              style: GoogleFonts.montserrat(
                                                fontSize: screenWidth * 0.05,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Model: ${vehicle['model'] ?? 'N/A'}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Type: ${vehicle['vehicleType'] ?? 'N/A'}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Reg: ${vehicle['registrationNumber'] ?? 'N/A'}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
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
            if (_isLoading)
              Container(
                color: Colors.black.withAlpha(128),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehiclePage()),
          );
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Vehicle',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        height: 55,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0, () => Navigator.pushReplacementNamed(context, '/home')),
            _buildNavItem(Icons.map, 'Route', 1, () => Navigator.pushReplacementNamed(context, '/route')),
            _buildNavItem(Icons.list, 'Trip List', 2, () => Navigator.pushReplacementNamed(context, '/search')),
            _buildNavItem(Icons.directions_car, 'Vehicle', 3, () {}),
            _buildNavItem(Icons.person, 'Profile', 4, () => Navigator.pushReplacementNamed(context, '/profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _currentIndex == index ? Colors.white : Colors.white.withAlpha(179),
            size: 20,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: _currentIndex == index ? Colors.white : Colors.white.withAlpha(179),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}