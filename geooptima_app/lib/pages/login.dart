import 'package:flutter/material.dart';
import 'package:geooptima_app/pages/otp-verification.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isPhoneFieldFocused = false;
  bool _isCountryDropdownOpen = false;
  bool _isGoogleImageLoaded = true;

  // Country code selection
  String _selectedCountryCode = '+91'; // Default to India
  String _selectedCountryFlag = '🇮🇳'; // Default flag

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
    _preloadGoogleImage();
  }

  void _preloadGoogleImage() {
    // Pre-check if image exists
    final imageProvider = AssetImage('assets/google_logo.png');
    imageProvider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, call) {
          setState(() {
            _isGoogleImageLoaded = true;
          });
        },
        onError: (exception, stackTrace) {
          setState(() {
            _isGoogleImageLoaded = false;
          });
          debugPrint('Google logo image failed to load: $exception');
        },
      ),
    );
  }

  void _onFocusChange() {
    setState(() {
      _isPhoneFieldFocused = _phoneFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.removeListener(_onFocusChange);
    _phoneFocusNode.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'Please enter a phone number';
    }
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  void _submitPhoneNumber() {
    final validationError = _validatePhoneNumber(_phoneController.text);
    if (validationError == null) {
      debugPrint(
        'Phone number submitted: $_selectedCountryCode ${_phoneController.text}',
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OtpVerificationScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
    }
  }

  void _toggleCountryDropdown() {
    setState(() {
      _isCountryDropdownOpen = !_isCountryDropdownOpen;
      if (_isCountryDropdownOpen) {
        _phoneFocusNode.unfocus();
      }
    });
    debugPrint('Dropdown toggled: $_isCountryDropdownOpen');
  }

  void _selectCountry(Map<String, String> country) {
    setState(() {
      _selectedCountryCode = country['code']!;
      _selectedCountryFlag = country['flag']!;
      _isCountryDropdownOpen = false;
    });
    debugPrint('Country selected: ${country['name']} (${country['code']})');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final widthRatio = screenWidth / 402;
    final heightRatio = screenHeight / 874;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background elements
          Container(
            width: screenWidth,
            height: screenHeight,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                // Polygon image
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
                        child: const Center(child: Text('G', style: TextStyle(color: Colors.white, fontSize: 40))),
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
                // Rotated black shape
                Positioned(
                  left: 211 * widthRatio,
                  top: -66.21 * heightRatio,
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
                // Rotated white shape
                Positioned(
                  left: 246 * widthRatio,
                  top: -22.14 * heightRatio,
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
                // "Did u miss us" text
                Positioned(
                  left: 21 * widthRatio,
                  top: 204 * heightRatio,
                  child: SizedBox(
                    width: 269 * widthRatio,
                    height: 156 * heightRatio,
                    child: Text(
                      'Did u\nmiss us',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 50 * widthRatio,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                // TextField container
                Positioned(
                  left: 27 * widthRatio,
                  top: 477 * heightRatio,
                  child: Container(
                    width: 347 * widthRatio,
                    height: 67 * heightRatio,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30 * widthRatio),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Country code dropdown button
                        GestureDetector(
                          onTap: _toggleCountryDropdown,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * widthRatio,
                              vertical: 15 * heightRatio,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedCountryFlag,
                                  style: TextStyle(fontSize: 20 * widthRatio),
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
                        // Vertical divider
                        Container(
                          height: 30 * heightRatio,
                          width: 1 * widthRatio,
                          color: Colors.grey[600],
                          margin: EdgeInsets.symmetric(
                            vertical: 18.5 * heightRatio,
                          ),
                        ),
                        // Phone number input field
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: _isPhoneFieldFocused ? '' : 'Enter registered number',
                              hintStyle: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 16 * widthRatio,
                                fontWeight: FontWeight.w500,
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
                ),
                // Submit button container
                Positioned(
                  left: 264 * widthRatio,
                  top: 601 * heightRatio,
                  child: GestureDetector(
                    onTap: _submitPhoneNumber,
                    child: Container(
                      width: 110 * widthRatio,
                      height: 51 * heightRatio,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3 * widthRatio),
                          borderRadius: BorderRadius.circular(30 * widthRatio),
                        ),
                      ),
                      child: Center(
                        child: Text(
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
                ),
                // Google sign-in button container
                Positioned(
                  left: 27 * widthRatio,
                  top: 771 * heightRatio,
                  child: GestureDetector(
                    onTap: () {
                      debugPrint('Google sign-in requested');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OtpVerificationScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 347 * widthRatio,
                      height: 67 * heightRatio,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3 * widthRatio,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(30 * widthRatio),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 15 * widthRatio),
                          Text(
                            'Did u sign in with google?',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 20 * widthRatio,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          // Google logo without errorBuilder
                          _isGoogleImageLoaded 
                              ?Container(
                            width: 35 * widthRatio,
                            height: 35 * heightRatio,
                            margin: EdgeInsets.only(right: 10 * widthRatio),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/google_logo.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 70 * widthRatio,
                                  height: 70 * heightRatio,
                                  child: Icon(
                                    Icons.g_mobiledata,
                                    color: Colors.red,
                                    size: 40 * widthRatio,
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
          // Tap-outside listener (below dropdown)
          if (_isCountryDropdownOpen)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  _isCountryDropdownOpen = false;
                });
                debugPrint('Tapped outside to close dropdown');
              },
              child: Container(color: Colors.transparent),
            ),
          // Country dropdown overlay (on top)
          if (_isCountryDropdownOpen && _countries.isNotEmpty)
            Positioned(
              left: 27 * widthRatio,
              top: (477 + 67) * heightRatio, // Below the phone field
              child: Container(
                width: 200 * widthRatio,
                height: 250 * heightRatio,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15 * widthRatio),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return GestureDetector(
                      onTap: () {
                        _selectCountry(country);
                        debugPrint('Tapped country: ${country['name']}');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10 * heightRatio,
                          horizontal: 15 * widthRatio,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          color:
                              _selectedCountryCode == country['code']
                                  ? Colors.grey.withOpacity(0.2)
                                  : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Text(
                              country['flag']!,
                              style: TextStyle(fontSize: 20 * widthRatio),
                            ),
                            SizedBox(width: 10 * widthRatio),
                            Expanded(
                              child: Text(
                                '${country['name']} (${country['code']})',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14 * widthRatio,
                                  fontWeight:
                                      _selectedCountryCode == country['code']
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}