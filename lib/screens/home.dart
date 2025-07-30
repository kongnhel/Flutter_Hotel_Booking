import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/roomType_model.dart';
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/screens/order_page.dart';
import 'package:hotel_booking/theme/color.dart'; // Ensure this path is correct
import 'package:hotel_booking/widgets/feature_item.dart'; // Ensure this path is correct
import 'package:http/http.dart' as http;

// Base URL for your API. For a real app, this should be configurable (e.g., environment variables).
const String kBaseUrl = 'http://localhost:3000/api';

class HomePage extends StatefulWidget {
  static const String id = '/HomePage';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedLocation;
  Map<String, String> roomTypeNames = {};
  List<Room> featuredRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // A single method to handle all initial data fetching
  Future<void> _initializeData() async {
    await fetchRoomTypes();
    await fetchFeaturedRooms();
  }

  Future<void> fetchFeaturedRooms() async {
    setState(() {
      isLoading = true; // Set loading to true before fetching
    });
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/rooms'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          featuredRooms = data.map((e) => Room.fromJson(e)).toList();
        });
      } else {
        // Log the error for debugging
        print('បរាជ័យក្នុងការទាញយកបន្ទប់, status: ${res.statusCode}');
        // Optionally show a user-friendly message
        _showSnackBar(
          'បរាជ័យក្នុងការទាញយកបន្ទប់។ សូមព្យាយាមម្តងទៀតពេលក្រោយ។',
          isError: true,
        );
      }
    } catch (e) {
      print('មានកំហុសពេលទាញយកបន្ទប់: $e');
      _showSnackBar(
        'មានកំហុសបណ្តាញ។ សូមពិនិត្យការតភ្ជាប់របស់អ្នក។',
        isError: true,
      );
    } finally {
      setState(() {
        isLoading =
            false; // Set loading to false after fetching (success or failure)
      });
    }
  }

  Future<void> fetchRoomTypes() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/room_types'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        List<RoomType> types = data.map((e) => RoomType.fromJson(e)).toList();
        setState(() {
          roomTypeNames = {for (var type in types) type.id: type.name};
        });
      } else {
        print(
          "បរាជ័យក្នុងការទាញយកប្រភេទបន្ទប់, status: ${response.statusCode}",
        );
        _showSnackBar('បរាជ័យក្នុងការទាញយកប្រភេទបន្ទប់។', isError: true);
      }
    } catch (e) {
      print('មានកំហុសពេលទាញយកប្រភេទបន្ទប់: $e');
      _showSnackBar('មានកំហុសបណ្តាញពេលទាញយកប្រភេទបន្ទប់។', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor, // Use a consistent background color
      appBar: AppBar(
        title: const Text(
          "ស្វែងរកកន្លែងស្នាក់នៅ", // "Find Accommodation"
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.cyan, // Use cyan color for AppBar
        elevation: 0,
        centerTitle: false, // Align title to start
      ),
      body: CustomScrollView(
        slivers: [SliverToBoxAdapter(child: _buildBody())],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          child: Text(
            "ស្វែងរក និងកក់", // "Find and Book"
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700, // Make it bolder
              color: AppColor.textColor,
            ),
          ),
        ),
        _buildCities(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: Text(
            "បន្ទប់ទាំងអស់", // "All Rooms"
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700, // Make it bolder
              color: AppColor.textColor,
            ),
          ),
        ),
        _buildFeatured(),
      ],
    );
  }

  Widget _buildFeatured() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            color: AppColor.cyan, // Use cyan color for loading indicator
          ),
        ),
      );
    }

    final filteredRooms = selectedLocation == null
        ? featuredRooms
        : featuredRooms
              .where((room) => room.location == selectedLocation)
              .toList();

    if (filteredRooms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "មិនមានបន្ទប់រកឃើញនៅក្នុងទីតាំងនេះទេ។",
            textAlign: TextAlign.center, // Center the text
            style: TextStyle(color: AppColor.labelColor, fontSize: 16),
          ), // "No rooms found in this location."
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: filteredRooms.length,
      options: CarouselOptions(
        height: 420, // Increased height for larger items
        enlargeCenterPage: true,
        disableCenter: true,
        viewportFraction: 0.85, // Increased viewport fraction for larger items
        enableInfiniteScroll:
            false, // Prevents infinite scrolling if not enough items
      ),
      itemBuilder: (context, index, realIndex) {
        final room = filteredRooms[index];
        return Stack(
          children: [
            // Pass a larger width to FeatureItem
            FeatureItem(
              data: room,
              roomTypeName:
                  roomTypeNames[room.roomTypeId] ??
                  'មិនស្គាល់ប្រភេទ', // Unknown Type
              width:
                  MediaQuery.of(context).size.width *
                  0.8, // Make FeatureItem responsive to carousel size
              onTapFavorite: () {
                setState(() {
                  final i = featuredRooms.indexWhere((r) => r.id == room.id);
                  if (i != -1) {
                    featuredRooms[i] = Room(
                      id: room.id,
                      name: room.name,
                      image: room.image,
                      price: room.price,
                      roomTypeId: room.roomTypeId,
                      rate: room.rate,
                      location: room.location,
                      isFavorited: !room.isFavorited,
                      albumImages: room.albumImages,
                      description: room.description,
                      isBooked: room.isBooked,
                    );
                  }
                });
              },
              onTap: room.isBooked
                  ? null // Disable tap if booked
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderViewPage(
                            roomData: room.toJson(),
                            roomTypeName:
                                roomTypeNames[room.roomTypeId] ??
                                'មិនស្គាល់ប្រភេទ',
                          ),
                        ),
                      );
                    },
            ),

            // Overlay to show "Room has been booked" message
            if (room.isBooked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      "បន្ទប់ត្រូវបានកក់ហើយ", // "Room has been booked"
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCities() {
    // Ensure uniqueLocations is populated after featuredRooms are fetched
    final uniqueLocations = featuredRooms
        .map((room) => room.location)
        .toSet()
        .toList();

    // Add 'All Rooms' option at the beginning
    final List<String> allOptions = [
      'បន្ទប់ទាំងអស់',
      ...uniqueLocations,
    ]; // "All Rooms"

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 5, 0, 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(allOptions.length, (index) {
          final location = allOptions[index];
          // Determine if the current chip is selected
          final bool isSelected =
              (selectedLocation == null && location == 'បន្ទប់ទាំងអស់') ||
              (selectedLocation == location);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // If 'All Rooms' is selected, set selectedLocation to null to show all rooms
                  selectedLocation = (location == 'បន្ទប់ទាំងអស់')
                      ? null
                      : location;
                });
              },
              child: Chip(
                label: Text(location),
                backgroundColor: isSelected
                    ? AppColor
                          .cyan // Use cyan color for selected chip
                    : Colors.grey[300],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // More rounded corners
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
