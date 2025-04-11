import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geooptima_app/pages/otp-verification.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  final String?
  verifiedPhoneNumber; // Optional pre-filled phone number from OTP

  const RegisterScreen({super.key, this.verifiedPhoneNumber});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final FocusNode _phoneFocusNode = FocusNode();
  bool _isPhoneFieldFocused = false;
  bool _isCountryDropdownOpen = false;
  bool _isLoading = false;
  bool _termsAccepted = false;
  bool _fieldsUnlocked = false;
  bool _isGoogleImageLoaded = false;

  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  bool _isGenderDropdownOpen = false;

  late AnimationController _animationController;

  String _selectedCountryCode = '+91';
  String _selectedCountryFlag = '🇮🇳';

  final List<Map<String, String>> _countries = [
    {'name': 'Afghanistan', 'code': '+93', 'flag': '🇦🇫'},
    {'name': 'Albania', 'code': '+355', 'flag': '🇦🇱'},
    {'name': 'Algeria', 'code': '+213', 'flag': '🇩🇿'},
    {'name': 'Andorra', 'code': '+376', 'flag': '🇦🇩'},
    {'name': 'Angola', 'code': '+244', 'flag': '🇦🇴'},
    {'name': 'Argentina', 'code': '+54', 'flag': '🇦🇷'},
    {'name': 'Armenia', 'code': '+374', 'flag': '🇦🇲'},
    {'name': 'Australia', 'code': '+61', 'flag': '🇦🇺'},
    {'name': 'Austria', 'code': '+43', 'flag': '🇦🇹'},
    {'name': 'Azerbaijan', 'code': '+994', 'flag': '🇦🇿'},
    {'name': 'Bahamas', 'code': '+1', 'flag': '🇧🇸'},
    {'name': 'Bahrain', 'code': '+973', 'flag': '🇧🇭'},
    {'name': 'Bangladesh', 'code': '+880', 'flag': '🇧🇩'},
    {'name': 'Barbados', 'code': '+1', 'flag': '🇧🇧'},
    {'name': 'Belarus', 'code': '+375', 'flag': '🇧🇾'},
    {'name': 'Belgium', 'code': '+32', 'flag': '🇧🇪'},
    {'name': 'Belize', 'code': '+501', 'flag': '🇧🇿'},
    {'name': 'Benin', 'code': '+229', 'flag': '🇧🇯'},
    {'name': 'Bhutan', 'code': '+975', 'flag': '🇧🇹'},
    {'name': 'Bolivia', 'code': '+591', 'flag': '🇧🇴'},
    {'name': 'Bosnia and Herzegovina', 'code': '+387', 'flag': '🇧🇦'},
    {'name': 'Botswana', 'code': '+267', 'flag': '🇧🇼'},
    {'name': 'Brazil', 'code': '+55', 'flag': '🇧🇷'},
    {'name': 'Brunei', 'code': '+673', 'flag': '🇧🇳'},
    {'name': 'Bulgaria', 'code': '+359', 'flag': '🇧🇬'},
    {'name': 'Burkina Faso', 'code': '+226', 'flag': '🇧🇫'},
    {'name': 'Burundi', 'code': '+257', 'flag': '🇧🇮'},
    {'name': 'Cambodia', 'code': '+855', 'flag': '🇰🇭'},
    {'name': 'Cameroon', 'code': '+237', 'flag': '🇨🇲'},
    {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
    {'name': 'Cape Verde', 'code': '+238', 'flag': '🇨🇻'},
    {'name': 'Central African Republic', 'code': '+236', 'flag': '🇨🇫'},
    {'name': 'Chad', 'code': '+235', 'flag': '🇹🇩'},
    {'name': 'Chile', 'code': '+56', 'flag': '🇨🇱'},
    {'name': 'China', 'code': '+86', 'flag': '🇨🇳'},
    {'name': 'Colombia', 'code': '+57', 'flag': '🇨🇴'},
    {'name': 'Comoros', 'code': '+269', 'flag': '🇰🇲'},
    {'name': 'Congo', 'code': '+242', 'flag': '🇨🇬'},
    {'name': 'Costa Rica', 'code': '+506', 'flag': '🇨🇷'},
    {'name': 'Croatia', 'code': '+385', 'flag': '🇭🇷'},
    {'name': 'Cuba', 'code': '+53', 'flag': '🇨🇺'},
    {'name': 'Cyprus', 'code': '+357', 'flag': '🇨🇾'},
    {'name': 'Czech Republic', 'code': '+420', 'flag': '🇨🇿'},
    {'name': 'Denmark', 'code': '+45', 'flag': '🇩🇰'},
    {'name': 'Djibouti', 'code': '+253', 'flag': '🇩🇯'},
    {'name': 'Dominican Republic', 'code': '+1', 'flag': '🇩🇴'},
    {'name': 'Ecuador', 'code': '+593', 'flag': '🇪🇨'},
    {'name': 'Egypt', 'code': '+20', 'flag': '🇪🇬'},
    {'name': 'El Salvador', 'code': '+503', 'flag': '🇸🇻'},
    {'name': 'Estonia', 'code': '+372', 'flag': '🇪🇪'},
    {'name': 'Ethiopia', 'code': '+251', 'flag': '🇪🇹'},
    {'name': 'Fiji', 'code': '+679', 'flag': '🇫🇯'},
    {'name': 'Finland', 'code': '+358', 'flag': '🇫🇮'},
    {'name': 'France', 'code': '+33', 'flag': '🇫🇷'},
    {'name': 'Gabon', 'code': '+241', 'flag': '🇬🇦'},
    {'name': 'Gambia', 'code': '+220', 'flag': '🇬🇲'},
    {'name': 'Georgia', 'code': '+995', 'flag': '🇬🇪'},
    {'name': 'Germany', 'code': '+49', 'flag': '🇩🇪'},
    {'name': 'Ghana', 'code': '+233', 'flag': '🇬🇭'},
    {'name': 'Greece', 'code': '+30', 'flag': '🇬🇷'},
    {'name': 'Grenada', 'code': '+1', 'flag': '🇬🇩'},
    {'name': 'Guatemala', 'code': '+502', 'flag': '🇬🇹'},
    {'name': 'Guinea', 'code': '+224', 'flag': '🇬🇳'},
    {'name': 'Guinea-Bissau', 'code': '+245', 'flag': '🇬🇼'},
    {'name': 'Guyana', 'code': '+592', 'flag': '🇬🇾'},
    {'name': 'Haiti', 'code': '+509', 'flag': '🇭🇹'},
    {'name': 'Honduras', 'code': '+504', 'flag': '🇭🇳'},
    {'name': 'Hong Kong', 'code': '+852', 'flag': '🇭🇰'},
    {'name': 'Hungary', 'code': '+36', 'flag': '🇭🇺'},
    {'name': 'Iceland', 'code': '+354', 'flag': '🇮🇸'},
    {'name': 'India', 'code': '+91', 'flag': '🇮🇳'},
    {'name': 'Indonesia', 'code': '+62', 'flag': '🇮🇩'},
    {'name': 'Iran', 'code': '+98', 'flag': '🇮🇷'},
    {'name': 'Iraq', 'code': '+964', 'flag': '🇮🇶'},
    {'name': 'Ireland', 'code': '+353', 'flag': '🇮🇪'},
    {'name': 'Israel', 'code': '+972', 'flag': '🇮🇱'},
    {'name': 'Italy', 'code': '+39', 'flag': '🇮🇹'},
    {'name': 'Jamaica', 'code': '+1', 'flag': '🇯🇲'},
    {'name': 'Japan', 'code': '+81', 'flag': '🇯🇵'},
    {'name': 'Jordan', 'code': '+962', 'flag': '🇯🇴'},
    {'name': 'Kazakhstan', 'code': '+7', 'flag': '🇰🇿'},
    {'name': 'Kenya', 'code': '+254', 'flag': '🇰🇪'},
    {'name': 'Kuwait', 'code': '+965', 'flag': '🇰🇼'},
    {'name': 'Kyrgyzstan', 'code': '+996', 'flag': '🇰🇬'},
    {'name': 'Latvia', 'code': '+371', 'flag': '🇱🇻'},
    {'name': 'Lebanon', 'code': '+961', 'flag': '🇱🇧'},
    {'name': 'Lesotho', 'code': '+266', 'flag': '🇱🇸'},
    {'name': 'Liberia', 'code': '+231', 'flag': '🇱🇷'},
    {'name': 'Libya', 'code': '+218', 'flag': '🇱🇾'},
    {'name': 'Liechtenstein', 'code': '+423', 'flag': '🇱🇮'},
    {'name': 'Lithuania', 'code': '+370', 'flag': '🇱🇹'},
    {'name': 'Luxembourg', 'code': '+352', 'flag': '🇱🇺'},
    {'name': 'Madagascar', 'code': '+261', 'flag': '🇲🇬'},
    {'name': 'Malawi', 'code': '+265', 'flag': '🇲🇼'},
    {'name': 'Malaysia', 'code': '+60', 'flag': '🇲🇾'},
    {'name': 'Maldives', 'code': '+960', 'flag': '🇲🇻'},
    {'name': 'Mali', 'code': '+223', 'flag': '🇲🇱'},
    {'name': 'Malta', 'code': '+356', 'flag': '🇲🇹'},
    {'name': 'Mexico', 'code': '+52', 'flag': '🇲🇽'},
    {'name': 'Moldova', 'code': '+373', 'flag': '🇲🇩'},
    {'name': 'Monaco', 'code': '+377', 'flag': '🇲🇨'},
    {'name': 'Mongolia', 'code': '+976', 'flag': '🇲🇳'},
    {'name': 'Montenegro', 'code': '+382', 'flag': '🇲🇪'},
    {'name': 'Morocco', 'code': '+212', 'flag': '🇲🇦'},
    {'name': 'Mozambique', 'code': '+258', 'flag': '🇲🇿'},
    {'name': 'Myanmar', 'code': '+95', 'flag': '🇲🇲'},
    {'name': 'Namibia', 'code': '+264', 'flag': '🇳🇦'},
    {'name': 'Nepal', 'code': '+977', 'flag': '🇳🇵'},
    {'name': 'Netherlands', 'code': '+31', 'flag': '🇳🇱'},
    {'name': 'New Zealand', 'code': '+64', 'flag': '🇳🇿'},
    {'name': 'Nicaragua', 'code': '+505', 'flag': '🇳🇮'},
    {'name': 'Niger', 'code': '+227', 'flag': '🇳🇪'},
    {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬'},
    {'name': 'North Korea', 'code': '+850', 'flag': '🇰🇵'},
    {'name': 'North Macedonia', 'code': '+389', 'flag': '🇲🇰'},
    {'name': 'Norway', 'code': '+47', 'flag': '🇳🇴'},
    {'name': 'Oman', 'code': '+968', 'flag': '🇴🇲'},
    {'name': 'Pakistan', 'code': '+92', 'flag': '🇵🇰'},
    {'name': 'Palestine', 'code': '+970', 'flag': '🇵🇸'},
    {'name': 'Panama', 'code': '+507', 'flag': '🇵🇦'},
    {'name': 'Papua New Guinea', 'code': '+675', 'flag': '🇵🇬'},
    {'name': 'Paraguay', 'code': '+595', 'flag': '🇵🇾'},
    {'name': 'Peru', 'code': '+51', 'flag': '🇵🇪'},
    {'name': 'Philippines', 'code': '+63', 'flag': '🇵🇭'},
    {'name': 'Poland', 'code': '+48', 'flag': '🇵🇱'},
    {'name': 'Portugal', 'code': '+351', 'flag': '🇵🇹'},
    {'name': 'Qatar', 'code': '+974', 'flag': '🇶🇦'},
    {'name': 'Romania', 'code': '+40', 'flag': '🇷🇴'},
    {'name': 'Russia', 'code': '+7', 'flag': '🇷🇺'},
    {'name': 'Rwanda', 'code': '+250', 'flag': '🇷🇼'},
    {'name': 'Saudi Arabia', 'code': '+966', 'flag': '🇸🇦'},
    {'name': 'Senegal', 'code': '+221', 'flag': '🇸🇳'},
    {'name': 'Serbia', 'code': '+381', 'flag': '🇷🇸'},
    {'name': 'Sierra Leone', 'code': '+232', 'flag': '🇸🇱'},
    {'name': 'Singapore', 'code': '+65', 'flag': '🇸🇬'},
    {'name': 'Slovakia', 'code': '+421', 'flag': '🇸🇰'},
    {'name': 'Slovenia', 'code': '+386', 'flag': '🇸🇮'},
    {'name': 'Somalia', 'code': '+252', 'flag': '🇸🇴'},
    {'name': 'South Africa', 'code': '+27', 'flag': '🇿🇦'},
    {'name': 'South Korea', 'code': '+82', 'flag': '🇰🇷'},
    {'name': 'South Sudan', 'code': '+211', 'flag': '🇸🇸'},
    {'name': 'Spain', 'code': '+34', 'flag': '🇪🇸'},
    {'name': 'Sri Lanka', 'code': '+94', 'flag': '🇱🇰'},
    {'name': 'Sudan', 'code': '+249', 'flag': '🇸🇩'},
    {'name': 'Sweden', 'code': '+46', 'flag': '🇸🇪'},
    {'name': 'Switzerland', 'code': '+41', 'flag': '🇨🇭'},
    {'name': 'Syria', 'code': '+963', 'flag': '🇸🇾'},
    {'name': 'Taiwan', 'code': '+886', 'flag': '🇹🇼'},
    {'name': 'Tajikistan', 'code': '+992', 'flag': '🇹🇯'},
    {'name': 'Tanzania', 'code': '+255', 'flag': '🇹🇿'},
    {'name': 'Thailand', 'code': '+66', 'flag': '🇹🇭'},
    {'name': 'Togo', 'code': '+228', 'flag': '🇹🇬'},
    {'name': 'Trinidad and Tobago', 'code': '+1', 'flag': '🇹🇹'},
    {'name': 'Tunisia', 'code': '+216', 'flag': '🇹🇳'},
    {'name': 'Turkey', 'code': '+90', 'flag': '🇹🇷'},
    {'name': 'Turkmenistan', 'code': '+993', 'flag': '🇹🇲'},
    {'name': 'Uganda', 'code': '+256', 'flag': '🇺🇬'},
    {'name': 'Ukraine', 'code': '+380', 'flag': '🇺🇦'},
    {'name': 'United Arab Emirates', 'code': '+971', 'flag': '🇦🇪'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'name': 'Uruguay', 'code': '+598', 'flag': '🇺🇾'},
    {'name': 'Uzbekistan', 'code': '+998', 'flag': '🇺🇿'},
    {'name': 'Vatican City', 'code': '+379', 'flag': '🇻🇦'},
    {'name': 'Venezuela', 'code': '+58', 'flag': '🇻🇪'},
    {'name': 'Vietnam', 'code': '+84', 'flag': '🇻🇳'},
    {'name': 'Yemen', 'code': '+967', 'flag': '🇾🇪'},
    {'name': 'Zambia', 'code': '+260', 'flag': '🇿🇲'},
    {'name': 'Zimbabwe', 'code': '+263', 'flag': '🇿🇼'},
  ];

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(_onFocusChange);

    if (widget.verifiedPhoneNumber != null) {
      final countryCode = _extractCountryCode(widget.verifiedPhoneNumber!);
      final number = _extractPhoneNumber(
        widget.verifiedPhoneNumber!,
        countryCode,
      );
      _phoneController.text = number;
      _fieldsUnlocked = true;

      for (var country in _countries) {
        if (country['code'] == countryCode) {
          _selectedCountryCode = country['code']!;
          _selectedCountryFlag = country['flag']!;
          break;
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isGoogleImageLoaded) {
      precacheImage(AssetImage('assets/google_logo.png'), context)
          .then((_) {
            if (mounted) {
              setState(() {
                _isGoogleImageLoaded = true;
              });
            }
          })
          .catchError((e) {
            print('Failed to load Google logo: $e');
          });
    }
  }

  String _extractCountryCode(String fullNumber) {
    RegExp regExp = RegExp(r'^\+\d{1,4}');
    final match = regExp.firstMatch(fullNumber);
    return match?.group(0) ?? '+91';
  }

  String _extractPhoneNumber(String fullNumber, String countryCode) {
    return fullNumber.substring(countryCode.length);
  }

  void _onFocusChange() {
    setState(() => _isPhoneFieldFocused = _phoneFocusNode.hasFocus);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneFocusNode.removeListener(_onFocusChange);
    _phoneFocusNode.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String value) {
    if (value.isEmpty) return 'Please enter a phone number';
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.length < 10)
      return 'Phone number must be at least 10 digits';
    return null;
  }

  String? _validateFullRegistration() {
    if (_nameController.text.isEmpty) {
      return 'Please enter your full name';
    }
    if (_emailController.text.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      return 'Please enter a valid email';
    }
    if (_dobController.text.isEmpty) {
      return 'Please enter your date of birth';
    }
    if (!_termsAccepted) {
      return 'Please accept the terms and conditions';
    }
    return null;
  }

  Future<void> _submitPhoneNumber() async {
    final fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';
    final validationError = _validatePhoneNumber(_phoneController.text);
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.122.137:5000/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': fullPhoneNumber}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpVerificationScreen(
                  phoneNumber: fullPhoneNumber,
                  isFromRegister: true,
                ),
          ),
        );

        if (result != null && result['verified'] == true) {
          setState(() {
            _fieldsUnlocked = true;
            _phoneController.text = _extractPhoneNumber(
              fullPhoneNumber,
              _selectedCountryCode,
            );
          });
        }
      } else {
        String errorMessage = 'Unknown error occurred';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          if (response.body.toLowerCase().contains('<!doctype') ||
              response.body.toLowerCase().contains('<html')) {
            if (response.body.toLowerCase().contains('duplicate')) {
              errorMessage = 'This phone number is already registered';
            } else {
              errorMessage = 'Registration failed. Please try again.';
            }
          } else {
            errorMessage = response.body;
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server: ${e.toString()}')),
      );
      debugPrint('Connection error: $e');
    }
  }

  Future<void> _submitFullRegistration() async {
    final fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';
    final validationError = _validateFullRegistration();

    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.122.137:5000/api/auth/complete-registration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': fullPhoneNumber,
          'fullName': _nameController.text,
          'email': _emailController.text,
          'gender': _selectedGender,
          'dateOfBirth': _dobController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );

        if (data['token'] != null) {
          debugPrint('Token received: ${data['token']}');
        }

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        String errorMessage = 'Registration failed';

        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Registration failed. Please try again.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server: ${e.toString()}')),
      );
      debugPrint('Registration error: $e');
    }
  }

  void _toggleCountryDropdown() {
    setState(() {
      _isCountryDropdownOpen = !_isCountryDropdownOpen;
      _isGenderDropdownOpen = false;
      if (_isCountryDropdownOpen) _phoneFocusNode.unfocus();
    });
    debugPrint('Dropdown toggled: $_isCountryDropdownOpen');
  }

  void _toggleGenderDropdown() {
    if (!_fieldsUnlocked) return;

    setState(() {
      _isGenderDropdownOpen = !_isGenderDropdownOpen;
      _isCountryDropdownOpen = false;
    });
  }

  void _selectCountry(Map<String, String> country) {
    setState(() {
      _selectedCountryCode = country['code']!;
      _selectedCountryFlag = country['flag']!;
      _isCountryDropdownOpen = false;
    });
    debugPrint('Country selected: ${country['name']} (${country['code']})');
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
      _isGenderDropdownOpen = false;
    });
  }

  Future<void> _selectDate() async {
    if (!_fieldsUnlocked) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final widthRatio = screenWidth / 402;
    final heightRatio = screenHeight / 874;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Decorative background elements (restored to original positions)
            Positioned(
              left: -4, // Original position
              top: 0, // Original position
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
              left: screenWidth * 0.00, // Original position
              top:
                  screenHeight *
                  -0.02, // Original position (slightly off-screen, but intentional)
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
            Positioned(
              left: 361.93 * widthRatio, // Original position
              top:
                  -206.18 *
                  heightRatio, // Original position (extends above screen)
              child: Transform(
                transform: Matrix4.identity()..rotateZ(1.16),
                child: Container(
                  width: 511 * widthRatio,
                  height: 297 * heightRatio,
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50 * widthRatio),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 246 * widthRatio, // Original position
              top:
                  -22.14 *
                  heightRatio, // Original position (slightly above screen)
              child: Transform(
                transform: Matrix4.identity()..rotateZ(-0.44),
                child: Container(
                  width: 131.39 * widthRatio,
                  height: 240.08 * heightRatio,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40 * widthRatio),
                        bottomLeft: Radius.circular(40 * widthRatio),
                        bottomRight: Radius.circular(40 * widthRatio),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 21 * widthRatio, 
              top: 170 * heightRatio, 
              child: Text(
                'Be a\nOptima',
                textAlign: TextAlign.left,
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 50 * widthRatio,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Main content
            SingleChildScrollView(
              child: Container(
                height: screenHeight, // Bounded height to resolve flex issue
                padding: EdgeInsets.symmetric(
                  horizontal: 27 * widthRatio,
                  vertical: 20 * heightRatio,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: (260 + 50) * heightRatio,
                    ), // Increased to avoid overlap with "Be a Optima"
                    Text(
                      _fieldsUnlocked
                          ? 'Fill the below details'
                          : 'Register yourself',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 24 * widthRatio,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20 * heightRatio),
                    if (!_fieldsUnlocked) ...[
                      // Phone input
                      Container(
                        width: 347 * widthRatio,
                        height: 67 * heightRatio,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFD9D9D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30 * widthRatio,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleCountryDropdown,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10 * widthRatio,
                                  vertical: 15 * heightRatio,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedCountryFlag,
                                      style: TextStyle(
                                        fontSize: 20 * widthRatio,
                                      ),
                                    ),
                                    SizedBox(width: 5 * widthRatio),
                                    Text(
                                      _selectedCountryCode,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 16 * widthRatio,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Icon(
                                      _isCountryDropdownOpen
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: Colors.black,
                                      size: 24 * widthRatio,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 30 * heightRatio,
                              width: 1 * widthRatio,
                              color: Colors.grey[600],
                              margin: EdgeInsets.symmetric(
                                vertical: 18.5 * heightRatio,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      _isPhoneFieldFocused
                                          ? ''
                                          : 'Enter your number',
                                  hintStyle: GoogleFonts.montserrat(
                                    color: Colors.grey[600],
                                    fontSize: 16 * widthRatio,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15 * widthRatio,
                                    vertical: 20 * heightRatio,
                                  ),
                                ),
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 18 * widthRatio,
                                  fontWeight: FontWeight.w500,
                                ),
                                onSubmitted: (_) => _submitPhoneNumber(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30 * heightRatio),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _isLoading ? null : _submitPhoneNumber,
                            child: Container(
                              width: 110 * widthRatio,
                              height: 51 * heightRatio,
                              decoration: ShapeDecoration(
                                color: const Color(0x4CD9D9D9),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 3 * widthRatio),
                                  borderRadius: BorderRadius.circular(
                                    30 * widthRatio,
                                  ),
                                ),
                              ),
                              child: Center(
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 3,
                                          ),
                                        )
                                        : Text(
                                          'Submit',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontSize: 20 * widthRatio,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Push Google button to bottom
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 40 * heightRatio),
                            child: GestureDetector(
                              onTap: () {
                                final phoneError = _validatePhoneNumber(
                                  _phoneController.text,
                                );
                                if (phoneError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(phoneError)),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => OtpVerificationScreen(
                                          phoneNumber:
                                              '$_selectedCountryCode${_phoneController.text}',
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 280 * widthRatio,
                                height: 67 * heightRatio,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 3 * widthRatio,
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      30 * widthRatio,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _isGoogleImageLoaded
                                        ? Container(
                                          width: 35 * widthRatio,
                                          height: 35 * heightRatio,
                                          margin: EdgeInsets.only(
                                            left: 15 * widthRatio,
                                            right: 10 * widthRatio,
                                          ),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                'assets/google_logo.png',
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                        : Icon(
                                          Icons.g_mobiledata,
                                          size: 40 * widthRatio,
                                          color: Colors.red,
                                        ),
                                    Text(
                                      'Sign in with Google',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 20 * widthRatio,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Full registration fields
                      Container(
                        width: 347 * widthRatio,
                        height: 60 * heightRatio,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFD9D9D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30 * widthRatio,
                            ),
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your full name',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey[600],
                              fontSize: 16 * widthRatio,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 25 * widthRatio,
                              vertical: 18 * heightRatio,
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 16 * widthRatio,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * heightRatio),
                      Container(
                        width: 347 * widthRatio,
                        height: 60 * heightRatio,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFD9D9D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30 * widthRatio,
                            ),
                          ),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'example@gmail.com',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey[600],
                              fontSize: 16 * widthRatio,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 25 * widthRatio,
                              vertical: 18 * heightRatio,
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 16 * widthRatio,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * heightRatio),
                      GestureDetector(
                        onTap: _toggleGenderDropdown,
                        child: Container(
                          width: 347 * widthRatio,
                          height: 60 * heightRatio,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30 * widthRatio,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 25 * widthRatio,
                                    vertical: 18 * heightRatio,
                                  ),
                                  child: Text(
                                    _selectedGender,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: 16 * widthRatio,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 15 * widthRatio,
                                ),
                                child: Icon(
                                  _isGenderDropdownOpen
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  size: 28 * widthRatio,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * heightRatio),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          width: 347 * widthRatio,
                          height: 60 * heightRatio,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30 * widthRatio,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 25 * widthRatio,
                                    vertical: 18 * heightRatio,
                                  ),
                                  child: Text(
                                    _dobController.text.isEmpty
                                        ? 'DD/MM/YYYY'
                                        : _dobController.text,
                                    style: GoogleFonts.montserrat(
                                      color:
                                          _dobController.text.isEmpty
                                              ? Colors.grey[600]
                                              : Colors.black,
                                      fontSize: 16 * widthRatio,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 15 * widthRatio,
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  size: 22 * widthRatio,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * heightRatio),
                      Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'Terms & conditions',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 14 * widthRatio,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20 * heightRatio),
                      Center(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _submitFullRegistration,
                          child: Container(
                            width: 180 * widthRatio,
                            height: 48 * heightRatio,
                            decoration: ShapeDecoration(
                              color: const Color(0x4CD9D9D9),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 3 * widthRatio),
                                borderRadius: BorderRadius.circular(
                                  30 * widthRatio,
                                ),
                              ),
                            ),
                            child: Center(
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 3,
                                        ),
                                      )
                                      : Text(
                                        'Create Account',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: 18 * widthRatio,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Country dropdown (adjusted position to match original intent)
            if (_isCountryDropdownOpen)
              Positioned(
                left: 27 * widthRatio,
                top:
                    447 *
                    heightRatio, // Matches original placement below phone input
                child: Container(
                  width: 347 * widthRatio,
                  height: 300 * heightRatio,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10 * widthRatio),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: _countries.length,
                    itemBuilder: (context, index) {
                      final country = _countries[index];
                      return InkWell(
                        onTap: () => _selectCountry(country),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15 * widthRatio,
                            vertical: 10 * heightRatio,
                          ),
                          child: Row(
                            children: [
                              Text(
                                country['flag']!,
                                style: TextStyle(fontSize: 24 * widthRatio),
                              ),
                              SizedBox(width: 10 * widthRatio),
                              Text(
                                '${country['code']} (${country['name']})',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16 * widthRatio,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            // Gender dropdown (adjusted position to match original intent)
            if (_isGenderDropdownOpen)
              Positioned(
                left: 27 * widthRatio,
                top:
                    650 *
                    heightRatio, // Matches original placement below gender field
                child: Container(
                  width: 347 * widthRatio,
                  height: 150 * heightRatio,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10 * widthRatio),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: _genderOptions.length,
                    itemBuilder: (context, index) {
                      final gender = _genderOptions[index];
                      return InkWell(
                        onTap: () => _selectGender(gender),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25 * widthRatio,
                            vertical: 15 * heightRatio,
                          ),
                          child: Text(
                            gender,
                            style: GoogleFonts.montserrat(
                              fontSize: 18 * widthRatio,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
