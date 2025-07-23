import 'dart:convert';

import 'package:flutter/material.dart';
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
  List<Room> filteredRooms = [];

  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  String? _selectedCity;
  String? _selectedCategory;
  int _guests = 1;
  int _rooms = 1;

  final List<Map<String, String>> cities = [
    {'name': 'Phnom Penh'},
    {'name': 'Siem Reap'},
    {'name': 'Sihanoukville'},
    {'name': 'Battambang'},
  ];

  final List<Map<String, String>> categories = [
    {'name': 'Luxury'},
    {'name': 'Standard'},
    {'name': 'Family'},
    {'name': 'Suite'},
  ];

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/rooms'));
      if (res.statusCode == 200) {
        final List jsonData = jsonDecode(res.body);
        setState(() {
          allRooms = jsonData.map((e) => Room.fromJson(e)).toList();
          filteredRooms = allRooms;
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
    final categoryQuery = _selectedCategory ?? '';

    final results = allRooms.where((room) {
      final matchLocation = room.location.toLowerCase().contains(
        cityQuery.toLowerCase(),
      );
      final matchCategory = room.roomTypeId.toLowerCase().contains(
        categoryQuery.toLowerCase(),
      );

      return matchLocation && matchCategory;
    }).toList();

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
      'category': categoryQuery.isNotEmpty ? categoryQuery : 'Any Category',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          searchParameters: searchParams,
          searchResults: results,
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
                    _buildDropdown(
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
                    _buildDropdown(
                      _selectedCategory,
                      categories,
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

  Widget _buildDropdown(
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
              value: item['name'],
              child: Text(item['name'] ?? ''),
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
