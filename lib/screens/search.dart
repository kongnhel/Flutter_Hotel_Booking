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
    {'name': 'ភ្នំពេញ'},
    {'name': 'សៀមរាប'},
    {'name': 'ព្រះសីហនុ'},
    {'name': 'បាត់ដំបង'},
    {'name': 'បន្ទាយមានជ័យ'},
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
        debugPrint(
          "បរាជ័យក្នុងការផ្ទុកប្រភេទបន្ទប់, ស្ថានភាព: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint('កំហុសក្នុងការទាញយកប្រភេទបន្ទប់: $e');
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
        debugPrint("បរាជ័យក្នុងការផ្ទុកបន្ទប់: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("កំហុសក្នុងការទាញយកបន្ទប់: $e");
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
        roomTypeNames[categoryIdQuery] ?? 'ប្រភេទណាមួយ';

    final searchParams = {
      'location': cityQuery.isNotEmpty ? cityQuery : 'គ្រប់ទីកន្លែង',
      'checkIn': _checkInController.text.isNotEmpty
          ? _checkInController.text
          : 'ថ្ងៃណាមួយ',
      'checkOut': _checkOutController.text.isNotEmpty
          ? _checkOutController.text
          : 'ថ្ងៃណាមួយ',
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
                    'បរាជ័យក្នុងការផ្ទុករូបភាព',
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "ត្រឡប់ក្រោយ",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.cyan, // Modern button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'សូមស្វាគមន៍មកកាន់ដំណើរផ្សងព្រេងបន្ទាប់របស់អ្នក!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan, // Cohesive color
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ស្វែងរកកន្លែងស្នាក់នៅដ៏ល្អឥតខ្ចោះជាមួយ WanderStay',
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    ),
                    const SizedBox(height: 24),

                    // City Dropdown
                    const Text(
                      'នៅឯណា?',
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
                      'ប្រភេទបន្ទប់',
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
                          backgroundColor:
                              Colors.cyan, // Modern button color
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5, // Add elevation for better look
                        ),
                        child: const Text(
                          'ស្វែងរក',
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
          hint: const Text("ជ្រើសរើសទីក្រុង"), // Add a hint text
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
          hint: const Text("ជ្រើសរើសប្រភេទបន្ទប់"), // Add a hint text
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
        Expanded(child: _buildDateField('ថ្ងៃចូល', _checkInController)),
        const SizedBox(width: 16),
        Expanded(child: _buildDateField('ថ្ងៃចេញ', _checkOutController)),
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
            'ភ្ញៀវ',
            _guests,
            (val) => setState(() => _guests = val),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCounter(
            'បន្ទប់',
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
          color: isAdd
              ? Colors.cyan
              : Colors.grey[300], // Consistent color
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: isAdd ? Colors.white : Colors.grey),
      ),
    );
  }
}
