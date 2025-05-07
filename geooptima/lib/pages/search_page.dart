import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add SharedPreferences package

class OlaPlacesService {
  static const MethodChannel _channel = MethodChannel('ola_places');

  static Future<void> initializePlaces(String apiKey, String baseUrl) async {
    try {
      await _channel.invokeMethod('initializePlaces', {
        'apiKey': apiKey,
        'baseUrl': baseUrl,
      });
    } catch (e) {
      developer.log('Error initializing Places SDK: $e', name: 'OlaPlacesService');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> autocomplete(String query) async {
    try {
      final result = await _channel.invokeMethod('autocomplete', {'query': query});
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      developer.log('Autocomplete error: $e', name: 'OlaPlacesService');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> nearbySearch(String location, int limit) async {
    try {
      final result = await _channel.invokeMethod('nearbySearch', {
        'location': location,
        'limit': limit,
      });
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      developer.log('Nearby search error: $e', name: 'OlaPlacesService');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> textSearch(String query, String location) async {
    try {
      final result = await _channel.invokeMethod('textSearch', {
        'query': query,
        'location': location,
      });
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      developer.log('Text search error: $e', name: 'OlaPlacesService');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> placeDetails(String placeId) async {
    try {
      final result = await _channel.invokeMethod('placeDetails', {'placeId': placeId});
      return result != null ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      developer.log('Place details error: $e', name: 'OlaPlacesService');
      return null;
    }
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _recentSearches = [];
  List<Map<String, dynamic>> _displayedSearches = [];
  List<Map<String, dynamic>> _autocompleteSuggestions = [];
  bool _isLoading = false;
  int _currentIndex = 2; // Assuming SearchPage is linked to 'Trip List' in nav
  String _backendUrl = '';
  String _placesApiKey = '';
  String _placesBaseUrl = '';
  final _storage = const FlutterSecureStorage();
  bool _showAll = false;
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _nearbyLocations = [];
  static const String _defaultLocation = '12.931316595874005,77.61649243443775'; // Bengaluru

  // Variables to store user data from SharedPreferences and secure storage
  bool _isLoggedIn = false;
  String? _phoneNumber;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data before proceeding
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _phoneNumber = prefs.getString('phoneNumber');

      // Load token from FlutterSecureStorage
      _authToken = await _storage.read(key: 'key_auth_token');

      // Check if user is logged in
      if (!_isLoggedIn || _authToken == null) {
        developer.log('User not logged in or token missing', name: 'SearchPage');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Proceed with loading backend URL and other data
      await _loadBackendUrl();
      await _loadRecentSearches();
    } catch (e) {
      developer.log('Error loading user data: $e', name: 'SearchPage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  Future<void> _loadBackendUrl() async {
    try {
      await dotenv.load(fileName: "assets/.env");
      setState(() {
        _backendUrl = dotenv.env['BACKEND_URL'] ?? 'https://backend-codecrib-cja0h8fdepdbfkgx.canadacentral-01.azurewebsites.net';
        _placesApiKey = dotenv.env['OLA_PLACES_API_KEY'] ?? '';
        _placesBaseUrl = dotenv.env['OLA_PLACES_BASE_URL'] ?? '';
      });
      if (_backendUrl.isEmpty || _placesApiKey.isEmpty || _placesBaseUrl.isEmpty) {
        throw Exception('Required env variables not found in .env file.');
      }
      // Initialize Places SDK
      await OlaPlacesService.initializePlaces(_placesApiKey, _placesBaseUrl);
      // Load nearby locations
      await _loadNearbyLocations();
    } catch (e) {
      developer.log('Backend/Places URL load error: $e', name: 'SearchPage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading configuration: $e')),
      );
    }
  }

  Future<void> _loadRecentSearches() async {
    setState(() => _isLoading = true);
    try {
      final url = '$_backendUrl/api/auth/search';
      developer.log('Fetching searches from $url with token: $_authToken', name: 'SearchPage');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      developer.log('Get searches response: Status ${response.statusCode}, Body: ${response.body}', name: 'SearchPage');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> searches = data['searches'] ?? [];
        setState(() {
          _recentSearches = searches
              .map((search) => {
                    'query': search['query'],
                    'place': search['place'],
                    'location': search['location'],
                    'timestamp': search['timestamp'],
                  })
              .toList();
          _displayedSearches = _recentSearches.take(5).toList();
          _showAll = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _recentSearches = [];
          _displayedSearches = [];
          _showAll = false;
        });
      } else {
        throw Exception('Failed to load searches: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      developer.log('Error loading searches: $e', name: 'SearchPage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading searches: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNearbyLocations() async {
    setState(() => _isLoading = true);
    try {
      final nearby = await OlaPlacesService.nearbySearch(_defaultLocation, 5);
      setState(() {
        _nearbyLocations = nearby;
      });
    } catch (e) {
      developer.log('Error loading nearby locations: $e', name: 'SearchPage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading nearby locations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchTextChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _autocompleteSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _performAutocomplete(query);
  }

  Future<void> _performAutocomplete(String query) async {
    setState(() => _isLoading = true);
    try {
      final suggestions = await OlaPlacesService.autocomplete(query);
      setState(() {
        _autocompleteSuggestions = suggestions;
        _showSuggestions = true;
      });
    } catch (e) {
      developer.log('Autocomplete error: $e', name: 'SearchPage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Autocomplete failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch(String query, {Map<String, dynamic>? suggestion}) async {
    if (query.isEmpty && suggestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search query or select a suggestion')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_authToken == null) {
        throw Exception('No authentication token found');
      }

      // Use suggestion data if provided, otherwise perform text search
      Map<String, dynamic> searchEntry;
      if (suggestion != null) {
        final placeDetails = await OlaPlacesService.placeDetails(suggestion['placeId']);
        searchEntry = {
          'query': query,
          'place': placeDetails?['name'] ?? suggestion['description'],
          'location': {
            'latitude': placeDetails?['geometry']?['location']?['lat'],
            'longitude': placeDetails?['geometry']?['location']?['lng'],
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        final results = await OlaPlacesService.textSearch(query, _defaultLocation);
        final firstResult = results.isNotEmpty ? results[0] : null;
        searchEntry = {
          'query': query,
          'place': firstResult?['name'] ?? query,
          'location': {
            'latitude': firstResult?['location']?['latitude'],
            'longitude': firstResult?['location']?['longitude'],
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      developer.log('Saving search to $_backendUrl/api/auth/search with token: $_authToken', name: 'SearchPage');
      final saveResponse = await http.post(
        Uri.parse('$_backendUrl/api/auth/search'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': searchEntry['query'],
          'place': searchEntry['place'],
          'location': searchEntry['location'],
        }),
      );

      developer.log('Save search response: Status ${saveResponse.statusCode}, Body: ${saveResponse.body}', name: 'SearchPage');

      if (saveResponse.statusCode == 200) {
        setState(() {
          _recentSearches.insert(0, searchEntry);
          _displayedSearches = _showAll ? _recentSearches : _recentSearches.take(5).toList();
          _autocompleteSuggestions = [];
          _showSuggestions = false;
        });
        _searchController.clear();
      } else {
        throw Exception('Failed to save search: Status ${saveResponse.statusCode}, Body: ${saveResponse.body}');
      }
    } catch (e) {
      developer.log('Search error: $e', name: 'SearchPage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMoreSearches() {
    setState(() {
      _displayedSearches = _recentSearches;
      _showAll = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for a place...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () => _performSearch(_searchController.text),
                              ),
                            ),
                            onSubmitted: _performSearch,
                          ),
                        ),
                        // Autocomplete Suggestions
                        if (_showSuggestions && _autocompleteSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _autocompleteSuggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = _autocompleteSuggestions[index];
                                return ListTile(
                                  title: Text(
                                    suggestion['description'] ?? '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    _searchController.text = suggestion['description'] ?? '';
                                    _performSearch(suggestion['description'], suggestion: suggestion);
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Nearby Locations
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Text(
                      'Nearby Locations',
                      style: GoogleFonts.montserrat(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: _nearbyLocations.isEmpty
                        ? Text(
                            'No nearby locations found',
                            style: GoogleFonts.montserrat(
                              fontSize: screenWidth * 0.05,
                              color: Colors.grey,
                            ),
                          )
                        : Container(
                            width: 344,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 2, color: Colors.black),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _nearbyLocations
                                      .map((location) => Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                _searchController.text = location['name'] ?? '';
                                                _performSearch(location['name'], suggestion: location);
                                              },
                                              child: Text(
                                                location['name'] ?? '',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: screenWidth * 0.05,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                  ),
                  // Recents Text
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Text(
                      'Recents',
                      style: GoogleFonts.montserrat(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Single Box with Recent Searches
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: _displayedSearches.isEmpty
                        ? Text(
                            'No recent searches',
                            style: GoogleFonts.montserrat(
                              fontSize: screenWidth * 0.05,
                              color: Colors.grey,
                            ),
                          )
                        : Column(
                            children: [
                              Container(
                                width: 344,
                                height: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 2, color: Colors.black),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: _displayedSearches
                                          .map((search) => Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _searchController.text = search['place'] ?? '';
                                                    _performSearch(search['place']);
                                                  },
                                                  child: Text(
                                                    search['place'],
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: screenWidth * 0.05,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                              if (_recentSearches.length > 5 && !_showAll)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: TextButton(
                                    onPressed: _showMoreSearches,
                                    child: Text(
                                      'Show More',
                                      style: GoogleFonts.montserrat(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
            _buildNavItem(Icons.list, 'Trip List', 2, () {}),
            _buildNavItem(Icons.directions_car, 'Vehicle', 3, () => Navigator.pushReplacementNamed(context, '/vehicle')),
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
            color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}