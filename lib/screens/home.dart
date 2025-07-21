import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/screens/order_page.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:hotel_booking/utils/data.dart';
import 'package:hotel_booking/widgets/city_item.dart';
import 'package:hotel_booking/widgets/feature_item.dart';
import 'package:hotel_booking/widgets/recommend_item.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  static const String id = '\HomePage';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Room> featuredRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // _loadFeaturedRooms();
    fetchFeaturedRooms();
  }

  Future<void> fetchFeaturedRooms() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/rooms'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
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

  // Future<void> _loadFeaturedRooms() async {
  //   // example for local static list in your utils/data.dart
  //   final List rawFeatures = features; // from your data.dart

  //   setState(() {
  //     featuredRooms = rawFeatures.map((e) => Room.fromJson(e)).toList();
  //   });
  // }

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
      return Center(child: CircularProgressIndicator());
    }
    if (featuredRooms.isEmpty) {
      return Center(child: Text("No featured rooms available."));
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 350,
        enlargeCenterPage: true,
        disableCenter: true,
        viewportFraction: .75,
      ),
      items: List.generate(featuredRooms.length, (index) {
        final room = featuredRooms[index];

        return FeatureItem(
          data: room,
          onTapFavorite: () {
            setState(() {
              featuredRooms[index] = Room(
                id: room.id,
                name: room.name,
                image: room.image,
                price: room.price,
                type: room.type,
                rate: room.rate,
                location: room.location,
                isFavorited: !room.isFavorited, // toggle favorite
                albumImages: room.albumImages,
                description: room.description,
              );
            });
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderViewPage(roomData: room.toJson()),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCities() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 5, 0, 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          cities.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CityItem(data: cities[index]),
          ),
        ),
      ),
    );
  }
}
