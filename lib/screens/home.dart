import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/order_page.dart'; // Make sure this import is correct
import 'package:hotel_booking/screens/register.dart';
import 'package:hotel_booking/screens/root_app.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:hotel_booking/utils/data.dart'; // This file should contain your 'features' data
import 'package:hotel_booking/widgets/city_item.dart';
import 'package:hotel_booking/widgets/feature_item.dart';
import 'package:hotel_booking/widgets/icon_box.dart';
import 'package:hotel_booking/widgets/notification_box.dart';
import 'package:hotel_booking/widgets/recommend_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(106, 60, 117, 174),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColor.appBarColor,
            pinned: true,
            snap: true,
            floating: true,
            title: _buildAppBar(),
          ),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        IconBox(
          child: Image.asset("assets/images/logo_2.png", width: 24, height: 24),
        ),
        const SizedBox(width: 3),
        Text(
          "Hotel Booking",
          style: TextStyle(color: AppColor.darker, fontSize: 13),
        ),

        const Spacer(),
        IconButton(
          icon: Icon(
            Icons.person_add_alt_1,
            color: AppColor.darker,
            size: 24,
          ), // Example register icon
          onPressed: () {
            // Navigate to your RegisterPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
        ),
        NotificationBox(notifiedNumber: 100),
      ],
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
            child: Text(
              "Find and Book",
              style: TextStyle(color: AppColor.labelColor, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Text(
              "The Best Hotel Rooms",
              style: TextStyle(
                color: AppColor.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
          ),
          _buildCities(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Text(
              "Featured",
              style: TextStyle(
                color: AppColor.textColor,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
          ),
          _buildFeatured(),
          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recommended",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textColor,
                  ),
                ),
                Text(
                  "See all",
                  style: TextStyle(fontSize: 14, color: AppColor.darker),
                ),
              ],
            ),
          ),
          _getRecommend(),
        ],
      ),
    );
  }

  _buildFeatured() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        enlargeCenterPage: true,
        disableCenter: true,
        viewportFraction: .75,
      ),
      items: List.generate(
        features.length,
        (index) => FeatureItem(
          data: features[index],
          onTapFavorite: () {
            setState(() {
              features[index]["is_favorited"] =
                  !features[index]["is_favorited"];
            });
          },
          onTap: () {
            final selectedRoom = features[index];
            // Instead of showDialog, navigate to OrderPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderViewPage(roomData: selectedRoom),
              ),
            );
          },
        ),
      ),
    );
  }

  _getRecommend() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        enlargeCenterPage: true,
        disableCenter: true,
        viewportFraction: .75,
      ),
      items: List.generate(
        features.length,
        (index) => RecommendItem(
          // Changed FeatureItem to RecommendItem
          data: features[index],
          onTapFavorite: () {
            setState(() {
              features[index]["is_favorited"] =
                  !features[index]["is_favorited"];
            });
          },
          onTap: () {
            final selectedRoom = features[index];
            // Instead of showDialog, navigate to OrderPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderViewPage(roomData: selectedRoom),
              ),
            );
          },
        ),
      ),
    );
  }

  _buildCities() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 5, 0, 10),
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
