import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/order_page.dart';
import 'package:hotel_booking/screens/profile.dart';
import 'package:hotel_booking/screens/register.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:hotel_booking/utils/data.dart';
import 'package:hotel_booking/widgets/city_item.dart';
import 'package:hotel_booking/widgets/feature_item.dart';
import 'package:hotel_booking/widgets/icon_box.dart';
import 'package:hotel_booking/widgets/notification_box.dart';
import 'package:hotel_booking/widgets/recommend_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email');
    });
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        IconBox(
          onPressed: () {},
          tooltip: '',
          child: Image.asset("assets/images/logo_2.png", width: 24, height: 24),
        ),
        const SizedBox(width: 3),
        Text(
          "Hotel Booking",
          style: TextStyle(color: AppColor.darker, fontSize: 13),
        ),
        const Spacer(),
        IconButton(
          icon: _userEmail != null
              ? ClipOval(
                  child: Image.asset(
                    "assets/images/profile_emty.png",
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.person_add_alt_1, color: AppColor.darker, size: 24),
          onPressed: () {
            if (_userEmail != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(email: _userEmail!),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            }
          },
          tooltip: _userEmail ?? "Register",
        ),
        NotificationBox(notifiedNumber: 100),
      ],
    );
  }

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

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Find and Book"),
          _buildCities(),
          const SizedBox(height: 10),
          _sectionTitle("Featured"),
          _buildFeatured(),
          const SizedBox(height: 15),
          _sectionTitle("Recommended", seeAll: true),

          _getRecommend(),
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

  Widget _getRecommend() {
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
          data: features[index],
          onTapFavorite: () {
            setState(() {
              features[index]["is_favorited"] =
                  !features[index]["is_favorited"];
            });
          },
          onTap: () {
            final selectedRoom = features[index];
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
