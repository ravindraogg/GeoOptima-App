import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSummaryScreen extends StatefulWidget {
  const ProfileSummaryScreen({super.key});

  @override
  State<ProfileSummaryScreen> createState() => _ProfileSummaryScreenState();
}

class _ProfileSummaryScreenState extends State<ProfileSummaryScreen>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadCachedProfile();
    _checkTokenAndFetchProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'key_auth_token');
    debugPrint('Retrieved token: $token');
    return token;
  }

  Future<void> _loadCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumber = prefs.getString('cached_phoneNumber') ?? '';
      _fullNameController.text = prefs.getString('cached_fullName') ?? '';
      _emailController.text = prefs.getString('cached_email') ?? '';
      _selectedGender = prefs.getString('cached_gender') != '' ? prefs.getString('cached_gender') : null;
      String? dob = prefs.getString('cached_dateOfBirth');
      if (dob != null && dob.isNotEmpty) {
        try {
          _selectedDateOfBirth = DateFormat('dd/MM/yyyy').parse(dob);
        } catch (e) {
          debugPrint('Failed to parse cached dateOfBirth: $dob');
        }
      }
    });
  }

  Future<void> _cacheProfileData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_phoneNumber', data['phoneNumber'] ?? '');
    await prefs.setString('cached_fullName', data['fullName'] ?? '');
    await prefs.setString('cached_email', data['email'] ?? '');
    await prefs.setString('cached_gender', data['gender'] ?? '');
    await prefs.setString('cached_dateOfBirth', data['dateOfBirth'] ?? '');
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
    _animationController.forward();
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('Token is null during fetch');
        setState(() {
          _errorMessage = 'Please log in to view your profile.';
        });
        return;
      }

      debugPrint('Token: $token');
      final response = await http.get(
        Uri.parse(
            'https://backend-codecrib-cja0h8fdepdbfkgx.canadacentral-01.azurewebsites.net/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Profile data: $data');
        await _cacheProfileData(data);
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
                _selectedDateOfBirth =
                    DateFormat('dd/MM/yyyy').parse(data['dateOfBirth']);
              } catch (e) {
                debugPrint('Failed to parse dateOfBirth: ${data['dateOfBirth']}');
              }
            }
          }
          _errorMessage = null;
        });
      } else if (response.statusCode == 401) {
        debugPrint('Received 401, attempting to refresh token');
        final newToken = await _refreshToken();
        if (newToken != null) {
          debugPrint('Retrying profile fetch with new token');
          final retryResponse = await http.get(
            Uri.parse(
                'https://backend-codecrib-cja0h8fdepdbfkgx.canadacentral-01.azurewebsites.net/api/auth/profile'),
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
          );
          if (retryResponse.statusCode == 200) {
            final data = jsonDecode(retryResponse.body);
            await _cacheProfileData(data);
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
                    _selectedDateOfBirth =
                        DateFormat('dd/MM/yyyy').parse(data['dateOfBirth']);
                  } catch (e) {
                    debugPrint('Failed to parse dateOfBirth: ${data['dateOfBirth']}');
                  }
                }
              }
              _errorMessage = null;
            });
          } else {
            await _handleUnauthorized();
          }
        } else {
          await _handleUnauthorized();
        }
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to fetch profile';
        debugPrint('Fetch profile error: $error');
        setState(() {
          _errorMessage = error;
        });
      }
    } catch (e) {
      debugPrint('Fetch profile exception: $e');
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
      _animationController.reverse();
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        debugPrint('No refresh token available');
        return null;
      }
      final refreshResponse = await http.post(
        Uri.parse(
            'https://backend-codecrib-cja0h8fdepdbfkgx.canadacentral-01.azurewebsites.net/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (refreshResponse.statusCode == 200) {
        final newToken = jsonDecode(refreshResponse.body)['token'];
        await _storage.write(key: 'jwt_token', value: newToken);
        debugPrint('Token refreshed successfully');
        return newToken;
      } else {
        debugPrint('Failed to refresh token: ${refreshResponse.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return null;
    }
  }

  Future<void> _handleUnauthorized() async {
    bool? logout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (logout == true) {
      await _storage.delete(key: 'jwt_token');
      await _storage.delete(key: 'refresh_token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('phoneNumber');
      setState(() {
        _errorMessage = 'Session expired. Please log in again.';
      });
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    _animationController.forward();
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
        Uri.parse(
            'https://backend-codecrib-cja0h8fdepdbfkgx.canadacentral-01.azurewebsites.net/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('Profile update response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        await _cacheProfileData(body);
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
      _animationController.reverse();
    }
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> _showLogoutConfirmation() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Confirm Logout',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Yes',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _logout();
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
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
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
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.grey,
                                                  size: constraints.maxWidth * 0.06,
                                                ),
                                                SizedBox(width: 5),
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
                                  Transform.translate(
                                    offset: Offset(0, -20),
                                    child: Container(
                                      width: double.infinity,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black, width: 2),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_errorMessage == null)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth * 0.04,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(context, 'Full name', _fullNameController, _isEditing,
                                      'Enter your full name'),
                                  SizedBox(height: constraints.maxHeight * 0.02),
                                  _buildTextField(context, 'Email', _emailController, _isEditing,
                                      'example@gmail.com'),
                                  SizedBox(height: constraints.maxHeight * 0.02),
                                  _buildGenderDropdown(context, _isEditing),
                                  SizedBox(height: constraints.maxHeight * 0.02),
                                  _buildDateOfBirthField(context, _isEditing),
                                  SizedBox(height: constraints.maxHeight * 0.02),
                                  Align(
                                    alignment: Alignment.center,
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
                                ],
                              ),
                            ),
                          const Spacer(),
                          if (_errorMessage == null)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: constraints.maxHeight * 0.04,
                              ),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: _showLogoutConfirmation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: constraints.maxWidth * 0.08,
                                      vertical: constraints.maxHeight * 0.02,
                                    ),
                                  ),
                                  child: Text(
                                    'Logout',
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
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Container(
                                width: 100 * (screenWidth / 392.7),
                                height: 100 * (screenWidth / 392.7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20 * (screenWidth / 392.7)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                                    strokeWidth: 6 * (screenWidth / 392.7),
                                    backgroundColor: Colors.grey[300],
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
            _buildNavItem(Icons.home, 'Home', 0,
                () => Navigator.pushReplacementNamed(context, '/home')),
            _buildNavItem(Icons.map, 'Route', 1,
                () => Navigator.pushReplacementNamed(context, '/route')),
            _buildNavItem(Icons.list, 'Trip List', 2,
                () => Navigator.pushReplacementNamed(context, '/trip-list')),
            _buildNavItem(Icons.directions_car, 'Vehicle', 3,
                () => Navigator.pushReplacementNamed(context, '/vehicle')),
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
              onChanged: isEditing
                  ? (String? newValue) => setState(() => _selectedGender = newValue)
                  : null,
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