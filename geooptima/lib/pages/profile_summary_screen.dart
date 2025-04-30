
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ProfileSummaryScreen extends StatefulWidget {
  const ProfileSummaryScreen({super.key});

  @override
  State<ProfileSummaryScreen> createState() => _ProfileSummaryScreenState();
}

class _ProfileSummaryScreenState extends State<ProfileSummaryScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String _phoneNumber = '';
  int _currentIndex = 0;
  final _storage = FlutterSecureStorage();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkTokenAndFetchProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    debugPrint('Retrieved token: $token');
    return token;
  }

  Future<void> _checkTokenAndFetchProfile() async {
    final token = await _getToken();
    if (token == null) {
      debugPrint('No token found');
      setState(() {
        _errorMessage = 'Please log in to view your profile.';
      });
      return;
    }
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('Token is null during fetch');
        setState(() {
          _errorMessage = 'Please log in to view your profile.';
        });
        return;
      }

      debugPrint('Fetching profile with token: $token');
      final response = await http.get(
        Uri.parse('https://backend-codecrib-cja0h8fdepdbfkgx.canadacentral-01.azurewebsites.net/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Profile fetch response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Profile data: $data');
        setState(() {
          _phoneNumber = data['phoneNumber'] ?? '';
          _fullNameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _selectedGender = data['gender'] != '' ? data['gender'] : null;
          if (data['dateOfBirth'] != null) {
            try {
              _selectedDateOfBirth = DateTime.parse(data['dateOfBirth']);
            } catch (e) {
              try {
                _selectedDateOfBirth = DateFormat('dd/MM/yyyy').parse(data['dateOfBirth']);
              } catch (e) {
                debugPrint('Failed to parse dateOfBirth: ${data['dateOfBirth']}');
              }
            }
          }
          _errorMessage = null;
        });
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to fetch profile';
        debugPrint('Fetch profile error: $error');
        setState(() {
          _errorMessage = error;
        });
        if (response.statusCode == 401) {
          debugPrint('Unauthorized, clearing token');
          await _storage.delete(key: 'jwt_token');
          setState(() {
            _errorMessage = 'Session expired. Please log in again.';
          });
        }
      }
    } catch (e) {
      debugPrint('Fetch profile exception: $e');
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('Token is null during update');
        setState(() {
          _errorMessage = 'Please log in to update your profile.';
        });
        return;
      }

      final body = {
        'phoneNumber': _phoneNumber,
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'gender': _selectedGender ?? '',
        'dateOfBirth': _selectedDateOfBirth != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
            : '',
      };

      debugPrint('Updating profile with body: $body');
      final response = await http.post(
        Uri.parse('https://backend-codecrib-cja0h8fdepdbfkgx.canadacentral-01.azurewebsites.net/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('Profile update response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
        );
        setState(() {
          _errorMessage = null;
        });
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to update profile';
        debugPrint('Update profile error: $error');
        setState(() {
          _errorMessage = error;
        });
        if (response.statusCode == 401) {
          debugPrint('Unauthorized, clearing token');
          await _storage.delete(key: 'jwt_token');
          setState(() {
            _errorMessage = 'Session expired. Please log in again.';
          });
        }
      }
    } catch (e) {
      debugPrint('Update profile exception: $e');
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header with "G" and "Profile Summary"
                          Container(
                            width: screenWidth,
                            height: screenHeight * 0.12,
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
                                      debugPrint('Image load error: $error');
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
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: EdgeInsets.all(10 * (screenWidth / 392.7)),
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
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                                    child: Text(
                                      'Profile Summary',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: constraints.maxWidth * 0.07,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Error or User Info
                          if (_errorMessage != null)
                            Padding(
                              padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                              child: Column(
                                children: [
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/login');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'Go to Login',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(constraints.maxWidth * 0.08),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _fullNameController.text.isNotEmpty
                                                  ? _fullNameController.text
                                                  : 'User',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: constraints.maxWidth * 0.08,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Bangalore, KA',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: constraints.maxWidth * 0.06,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: constraints.maxWidth * 0.22,
                                          height: constraints.maxWidth * 0.22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(Icons.person, color: Colors.white, size: 50),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black, width: 2),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _emailController.text.isNotEmpty
                                                ? _emailController.text
                                                : 'No email',
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            _phoneNumber.isNotEmpty
                                                ? _phoneNumber
                                                : 'No phone number',
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            _selectedGender ?? 'No gender selected',
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Input fields
                          if (_errorMessage == null)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth * 0.04,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(context, 'Full name', _fullNameController, _isEditing, 'Enter your full name'),
                                  SizedBox(height: constraints.maxHeight * 0.02),
                                  _buildTextField(context, 'Email', _emailController, _isEditing, 'example@gmail.com'),
                                  SizedBox(height: constraints.maxHeight * 0.02),
                                  _buildGenderDropdown(context, _isEditing),
                                  SizedBox(height: constraints.maxHeight * 0.02),
                                  _buildDateOfBirthField(context, _isEditing),
                                ],
                              ),
                            ),
                          const Spacer(),
                          if (_errorMessage == null)
                            Padding(
                              padding: EdgeInsets.only(
                                right: constraints.maxWidth * 0.04,
                                bottom: constraints.maxHeight * 0.02,
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() => _isEditing = !_isEditing);
                                    if (!_isEditing) {
                                      _updateProfile();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: constraints.maxWidth * 0.08,
                                      vertical: constraints.maxHeight * 0.02,
                                    ),
                                  ),
                                  child: Text(
                                    _isEditing ? 'Save' : 'Edit',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: constraints.maxWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_isLoading)
                        Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 30),
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
            _buildNavItem(Icons.list, 'Trip List', 2, () => Navigator.pushReplacementNamed(context, '/trip_list')),
            _buildNavItem(Icons.directions_car, 'Vehicle', 3, () => Navigator.pushReplacementNamed(context, '/vehicle')),
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
            color: _currentIndex == index ? Colors.white : const Color.fromRGBO(255, 255, 255, 180),
            size: 20,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: _currentIndex == index ? Colors.white : const Color.fromRGBO(255, 255, 255, 180),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    bool isEditing,
    String hintText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.06,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: controller,
            enabled: isEditing,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(BuildContext context, bool isEditing) {
    final List<String> genderOptions = ['Male', 'Female', 'Other'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.06,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              hint: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text('Select Gender'),
              ),
              onChanged: isEditing ? (String? newValue) => setState(() => _selectedGender = newValue) : null,
              items: genderOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(value),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField(BuildContext context, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        GestureDetector(
          onTap: isEditing
              ? () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateOfBirth ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDateOfBirth = picked);
                  }
                }
              : null,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    _selectedDateOfBirth == null
                        ? 'Select Date'
                        : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.calendar_today),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}