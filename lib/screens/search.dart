import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // No longer explicitly used for SystemChrome
import 'package:hotel_booking/models/roomType_model.dart';
import 'package:http/http.dart' as http;
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/screens/search_result_page.dart';

const String kBaseUrl =
    'http://localhost:3000/api'; // Update to your backend URL

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Room> allRooms = [];
  // filteredRooms is not directly used in this class for display,
  // but rather for the search results page.
  // List<Room> filteredRooms = []; // Can remove this if not used for local display

  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  String? _selectedCity; // Holds the city name
  String? _selectedCategory; // Holds the roomType ID
  int _guests = 1;
  int _rooms = 1;

  final List<Map<String, String>> cities = [
    {'name': 'Phnom Penh'},
    {'name': 'Siem Reap'},
    {'name': 'Sihanoukville'},
    {'name': 'Battambang'},
  ];

  Map<String, String> roomTypeNames =
      {}; // key: roomTypeId, value: roomTypeName

  @override
  void initState() {
    super.initState();
    fetchRooms();
    fetchRoomTypes();
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }

  Future<void> fetchRoomTypes() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/room_types'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        List<RoomType> types = data.map((e) => RoomType.fromJson(e)).toList();
        setState(() {
          roomTypeNames = {for (var type in types) type.id: type.name};
          // Set a default selected category if none is selected and types are available
          if (_selectedCategory == null && roomTypeNames.isNotEmpty) {
            _selectedCategory = roomTypeNames.keys.first;
          }
        });
      } else {
        debugPrint("Failed to load room types, status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error fetching room types: $e');
    }
  }

  Future<void> fetchRooms() async {
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/rooms'));
      if (res.statusCode == 200) {
        final List jsonData = jsonDecode(res.body);
        setState(() {
          allRooms = jsonData.map((e) => Room.fromJson(e)).toList();
          // filteredRooms = allRooms; // No longer needed for local display
        });
      } else {
        debugPrint("Failed to load rooms: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching rooms: $e");
    }
  }

  void _handleSearch() {
    final cityQuery = _selectedCity ?? '';
    final categoryIdQuery = _selectedCategory ?? ''; // This is the ID

    final results = allRooms.where((room) {
      final matchLocation = room.location.toLowerCase().contains(
        cityQuery.toLowerCase(),
      );
      // Match by roomTypeId (the ID from the dropdown)
      final matchCategory = room.roomTypeId.toLowerCase().contains(
        categoryIdQuery.toLowerCase(),
      );

      return matchLocation && matchCategory;
    }).toList();

    // Get the display name for the category
    final String categoryDisplayName =
        roomTypeNames[categoryIdQuery] ?? 'Any Category';

    final searchParams = {
      'location': cityQuery.isNotEmpty ? cityQuery : 'Anywhere',
      'checkIn': _checkInController.text.isNotEmpty
          ? _checkInController.text
          : 'Any Date',
      'checkOut': _checkOutController.text.isNotEmpty
          ? _checkOutController.text
          : 'Any Date',
      'guests': _guests,
      'rooms': _rooms,
      'category': categoryDisplayName, // Pass the display name
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          searchParameters: searchParams,
          searchResults: results,
          roomTypeNames: roomTypeNames, // Pass the map for results page to use
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://placehold.co/600x400/ADD8E6/000000?text=Hotel+Background',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Back"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Welcome to your next\nAdventure!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Discover the Perfect Stay with WanderStay',
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    ),
                    const SizedBox(height: 24),

                    // City Dropdown
                    const Text(
                      'Where?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCityDropdown(
                      _selectedCity,
                      cities,
                      (val) => setState(() => _selectedCity = val),
                    ),

                    const SizedBox(height: 24),
                    _buildDateFields(),
                    const SizedBox(height: 24),
                    _buildCounterSection(),
                    const SizedBox(height: 24),

                    // Room Category
                    const Text(
                      'Room Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(
                      _selectedCategory,
                      roomTypeNames,
                      (val) => setState(() => _selectedCategory = val),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'FIND',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    );
  }

  // Generic dropdown for simple lists like cities
  Widget _buildCityDropdown(
    String? value,
    List<Map<String, String>> list,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          onChanged: onChanged,
          items: list.map((item) {
            return DropdownMenuItem<String>(
              value: item['name'], // Value is the city name
              child: Text(item['name'] ?? ''),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Specific dropdown for room categories (using ID as value, name as display)
  Widget _buildCategoryDropdown(
    String? value, // This value will be the roomType ID
    Map<String, String> roomTypesMap, // Map of ID to Name
    Function(String?) onChanged, // Callback receives the selected ID
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          onChanged: onChanged,
          items: roomTypesMap.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key, // Value is the roomType ID
              child: Text(entry.value), // Display is the roomType Name
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        Expanded(child: _buildDateField('Check-in', _checkInController)),
        const SizedBox(width: 16),
        Expanded(child: _buildDateField('Check-out', _checkOutController)),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'DD/MM/YY',
              border: InputBorder.none,
              suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
            ),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text =
                      "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString().substring(2)}";
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCounterSection() {
    return Row(
      children: [
        Expanded(
          child: _buildCounter(
            'Guests',
            _guests,
            (val) => setState(() => _guests = val),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCounter(
            'Room',
            _rooms,
            (val) => setState(() => _rooms = val),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCounterButton(
                Icons.remove,
                () => onChanged(value > 1 ? value - 1 : 1),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildCounterButton(
                Icons.add,
                () => onChanged(value + 1),
                isAdd: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton(
    IconData icon,
    VoidCallback onTap, {
    bool isAdd = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAdd ? Colors.blue : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: isAdd ? Colors.white : Colors.grey),
      ),
    );
  }
}
