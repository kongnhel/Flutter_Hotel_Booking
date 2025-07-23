import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/roomType_model.dart'; // Make sure this path is correct
import 'package:hotel_booking/models/room_model.dart'; // Make sure this path is correct
import 'package:hotel_booking/screens/order_page.dart';
import 'package:hotel_booking/screens/search.dart'; // Assuming search.dart is where kBaseUrl might be defined or you define it here
import 'package:hotel_booking/theme/color.dart';
import 'package:hotel_booking/widgets/feature_item.dart'; // Make sure this path is correct
import 'package:http/http.dart' as http;

// Define kBaseUrl here if it's not defined in a globally accessible file
const String kBaseUrl = 'http://localhost:3000/api'; // Or your actual base URL

class HomePage extends StatefulWidget {
  static const String id = '\HomePage';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedLocation;
  Map<String, String> roomTypeNames =
      {}; // key: roomTypeId, value: roomTypeName

  List<Room> featuredRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch room types first, then rooms
    fetchRoomTypes().then((_) {
      fetchFeaturedRooms();
    });
  }

  Future<void> fetchFeaturedRooms() async {
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/rooms')); // Use kBaseUrl
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          // Ensure roomTypeId is correctly mapped from the backend response
          featuredRooms = data.map((e) => Room.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch rooms, status: ${res.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      setState(() {
        isLoading = false;
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
        print("Failed to load room types, status: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching room types: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(106, 60, 117, 174),
      body: CustomScrollView(
        slivers: [SliverToBoxAdapter(child: _buildBody())],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Find and Book"),
          _buildCities(),
          const SizedBox(height: 10),
          _sectionTitle("All Rooms"),
          _buildFeatured(),
          const SizedBox(height: 15),
          _sectionTitle("Recommended", seeAll: true),
        ],
      ),
    );
  }

  Widget _sectionTitle(String label, {String? subtitle, bool seeAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textColor,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: AppColor.labelColor),
                ),
            ],
          ),
          if (seeAll)
            Text(
              "See all",
              style: TextStyle(fontSize: 14, color: AppColor.darker),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatured() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredRooms = selectedLocation == null
        ? featuredRooms
        : featuredRooms
              .where((room) => room.location == selectedLocation)
              .toList();

    if (filteredRooms.isEmpty) {
      return const Center(child: Text("No rooms found in this location."));
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 350,
        enlargeCenterPage: true,
        disableCenter: true,
        viewportFraction: .75,
      ),
      items: List.generate(filteredRooms.length, (index) {
        final room = filteredRooms[index];
        return FeatureItem(
          data: room,
          roomTypeName:
              roomTypeNames[room.roomTypeId] ??
              'Unknown Type', // <--- Pass the name here
          onTapFavorite: () {
            setState(() {
              final i = featuredRooms.indexWhere((r) => r.id == room.id);
              if (i != -1) {
                final updatedRoom = Room(
                  id: room.id,
                  name: room.name,
                  image: room.image,
                  price: room.price,
                  roomTypeId: room.roomTypeId, // Keep the ID
                  rate: room.rate,
                  location: room.location,
                  isFavorited: !room.isFavorited,
                  albumImages: room.albumImages,
                  description: room.description,
                );
                featuredRooms[i] = updatedRoom;
              }
            });
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderViewPage(
                  roomData: room.toJson(),
                  roomTypeName:
                      roomTypeNames[room.roomTypeId] ??
                      'Unknown Type', // Also pass to OrderViewPage
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCities() {
    final uniqueLocations = featuredRooms
        .map((room) => room.location)
        .toSet()
        .toList();

    final List<String> allOptions = ['All Rooms', ...uniqueLocations];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 5, 0, 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(allOptions.length, (index) {
          final location = allOptions[index];
          final isSelected =
              (selectedLocation == null && location == 'All Rooms') ||
              (selectedLocation == location);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (location == 'All Rooms') {
                    selectedLocation = null;
                  } else {
                    selectedLocation = location;
                  }
                });
              },
              child: Chip(
                label: Text(location),
                backgroundColor: isSelected
                    ? AppColor
                          .inActiveColor // Replace with your primary color
                    : Colors.grey[300],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
