import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/search_result_page.dart';
// Assuming app-data-list is in utils/data.dart
import 'package:hotel_booking/utils/data.dart'; // Import your data list

// Removed void main() and MyApp class as RootApp is the main entry point

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // State variables for guests and rooms
  int _guests = 1;
  int _rooms = 1;
  String? _selectedCategory; // State for selected category
  String? _selectedCity; // State for selected city

  // Controllers for text fields (to get their values)
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with the first category, or 'All' if available
    if (categories.isNotEmpty) {
      _selectedCategory = categories[0]['name'];
    }
    // Initialize with the first city if available
    if (cities.isNotEmpty) {
      _selectedCity = cities[0]['name'];
    }
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background of the entire screen
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://placehold.co/600x400/ADD8E6/000000?text=Hotel+Background', // Placeholder image
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          // Gradient Overlay (optional, for better text readability)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Main content card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              constraints: const BoxConstraints(
                maxWidth: 600,
              ), // Max width for larger screens
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.arrow_back),
                          label: Text("Back"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(
                          width: 12,
                        ), // spacing between button and text
                        Expanded(
                          // so long text doesn't overflow
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome to your next\nAdventure!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Text(
                      'Discover the Perfect Stay with WanderStay',
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    ),
                    const SizedBox(height: 24),

                    // Where? City Dropdown
                    const Text(
                      'Where?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCity,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                          hint: const Text('Select a city'),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCity = newValue;
                            });
                          },
                          items: cities.map<DropdownMenuItem<String>>((city) {
                            return DropdownMenuItem<String>(
                              value: city['name'],
                              child: Text(city['name']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Check-in and Check-out fields
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check-in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: TextField(
                                  controller:
                                      _checkInController, // Assign controller
                                  readOnly:
                                      true, // Make it read-only to simulate date picker
                                  decoration: const InputDecoration(
                                    hintText: 'DD/MM/YY',
                                    border: InputBorder.none,
                                    suffixIcon: Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                  ),
                                  onTap: () async {
                                    // Implement date picker
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        _checkInController.text =
                                            "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString().substring(2)}";
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check-out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: TextField(
                                  controller:
                                      _checkOutController, // Assign controller
                                  readOnly:
                                      true, // Make it read-only to simulate date picker
                                  decoration: const InputDecoration(
                                    hintText: 'DD/MM/YY',
                                    border: InputBorder.none,
                                    suffixIcon: Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                  ),
                                  onTap: () async {
                                    // Implement date picker
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        _checkOutController.text =
                                            "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString().substring(2)}";
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Guests and Room fields
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Guests',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCounterField(
                                _guests,
                                (value) => setState(() => _guests = value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Room',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCounterField(
                                _rooms,
                                (value) => setState(() => _rooms = value),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Room Category Dropdown
                    const Text(
                      'Room Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                          hint: const Text('Select a category'),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          items: categories.map<DropdownMenuItem<String>>((
                            category,
                          ) {
                            return DropdownMenuItem<String>(
                              value: category['name'],
                              child: Text(category['name']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // FIND Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Collect all search parameters
                          final Map<String, dynamic> searchParams = {
                            'location':
                                _selectedCity ??
                                'Anywhere', // Use selected city
                            'checkIn': _checkInController.text.isNotEmpty
                                ? _checkInController.text
                                : 'Any Date',
                            'checkOut': _checkOutController.text.isNotEmpty
                                ? _checkOutController.text
                                : 'Any Date',
                            'guests': _guests,
                            'rooms': _rooms,
                            'category': _selectedCategory ?? 'Any Category',
                          };

                          // Navigate to SearchResultsPage, passing the parameters
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultsPage(
                                searchParameters: searchParams,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
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

  // Helper widget for increment/decrement counter fields
  Widget _buildCounterField(int value, Function(int) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (value > 1) onChanged(value - 1);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, size: 18, color: Colors.grey),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          GestureDetector(
            onTap: () {
              onChanged(value + 1);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
