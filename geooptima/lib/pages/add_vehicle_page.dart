import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _storage = const FlutterSecureStorage();
  String _backendUrl = '';
  final double widthRatio = 1.0;
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _isDefaultController = TextEditingController();

  // Dropdown values
  String? _vehicleType;
  String? _vehicleSize;
  String? _fuelType;

  // Dropdown options
  final List<String> _vehicleTypeOptions = [
    'Bike',
    'Car',
    'Truck',
    'Van',
    'Bus',
    'SUV',
    'Motorcycle',
    'Scooter',
  ];
  final List<String> _vehicleSizeOptions = ['Small', 'Medium', 'Big'];
  final List<String> _fuelTypeOptions = ['Petrol', 'Diesel', 'EV'];

  // File picker for image
  PlatformFile? _imageFile;
  Uint8List? _webImageBytes; // For web image display and upload

  @override
  void initState() {
    super.initState();
    _loadBackendUrl();
  }

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _vehicleModelController.dispose();
    _registrationNumberController.dispose();
    _isDefaultController.dispose();
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
      // ignore: avoid_print
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

  Future<void> _pickImage() async {
    try {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      input.onChange.listen((e) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files.first;
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) {
            if (mounted) {
              setState(() {
                _webImageBytes = reader.result as Uint8List;
                _imageFile = PlatformFile(
                  name: file.name,
                  size: file.size,
                  bytes: _webImageBytes,
                );
              });
            }
          });
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveVehicle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final token = await _getToken();
    if (token == null) {
      // ignore: avoid_print
      print('No JWT token found');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    final vehicleType = _vehicleType;
    final name = _vehicleNameController.text.trim();
    final model = _vehicleModelController.text.trim();
    final registrationNumber = _registrationNumberController.text.trim();
    final vehicleSize = _vehicleSize;
    final fuelType = _fuelType;
    final isDefault = _isDefaultController.text.trim().toLowerCase() == 'yes';

    if (vehicleType == null || name.isEmpty || model.isEmpty || registrationNumber.isEmpty || vehicleSize == null || fuelType == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required')),
        );
      }
      return;
    }

    try {
      // ignore: avoid_print
      print('Saving vehicle to $_backendUrl/api/auth/vehicle with token: $token');
      var request = http.MultipartRequest('POST', Uri.parse('$_backendUrl/api/auth/vehicle'))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = name
        ..fields['model'] = model
        ..fields['vehicleType'] = vehicleType
        ..fields['registrationNumber'] = registrationNumber
        ..fields['sizeWeight'] = vehicleSize
        ..fields['fuelType'] = fuelType
        ..fields['isDefault'] = isDefault.toString();

      if (_imageFile != null && _webImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _webImageBytes!,
            filename: _imageFile!.name,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully!')),
          );
          Navigator.pop(context); // Return to VehiclePage
        }
      } else {
        throw Exception('Failed to save vehicle: Status ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error saving vehicle: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving vehicle: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                      // ignore: avoid_print
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
                    SizedBox(height: screenHeight * 0.07),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Text(
                        'Add Vehicle',
                        style: GoogleFonts.montserrat(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_car, color: Colors.red),
                              const SizedBox(width: 10),
                              Text(
                                'Vehicle Type',
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _vehicleType,
                            hint: Text(
                              'Select Vehicle Type',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  _vehicleType = value;
                                });
                              }
                            },
                            items: _vehicleTypeOptions.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            dropdownColor: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.drive_file_rename_outline, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                'Vehicle Name',
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _vehicleNameController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Toyota Camry',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.drive_file_rename_outline, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                'Vehicle Model',
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _vehicleModelController,
                            decoration: InputDecoration(
                              hintText: 'e.g., 2020',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.confirmation_number, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                'Registration Number',
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _registrationNumberController,
                            decoration: InputDecoration(
                              hintText: 'e.g., ABC123',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.local_shipping, color: Colors.green),
                              const SizedBox(width: 10),
                              Text(
                                'Vehicle Size',
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _vehicleSize,
                            hint: Text(
                              'Select Vehicle Size',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  _vehicleSize = value;
                                });
                              }
                            },
                            items: _vehicleSizeOptions.map((String size) {
                              return DropdownMenuItem<String>(
                                value: size,
                                child: Text(size),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            dropdownColor: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.local_gas_station, color: Colors.red),
                              const SizedBox(width: 10),
                              Text(
                                'Fuel Type',
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _fuelType,
                            hint: Text(
                              'Select Fuel Type',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  _fuelType = value;
                                });
                              }
                            },
                            items: _fuelTypeOptions.map((String fuel) {
                              return DropdownMenuItem<String>(
                                value: fuel,
                                child: Text(fuel),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            dropdownColor: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                'Default Vehicle?',
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _isDefaultController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Yes/No',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: _webImageBytes == null
                                      ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey))
                                      : ClipOval(
                                          child: Image.memory(
                                            _webImageBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Add Vehicle Image',
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveVehicle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'ADD',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// Temporary PlatformFile class for web compatibility
class PlatformFile {
  final String name;
  final int size;
  final Uint8List? bytes;

  PlatformFile({
    required this.name,
    required this.size,
    this.bytes,
  });
}