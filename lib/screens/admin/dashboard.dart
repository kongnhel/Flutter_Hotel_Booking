import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/sidebar_screen/orders_screen.dart';
import 'package:hotel_booking/screens/sidebar_screen/room/room_list.dart';
import 'package:hotel_booking/screens/sidebar_screen/user_management.dart';
import 'package:hotel_booking/theme/color.dart'; // Ensure this path is correct

class AdminDashboardPage extends StatefulWidget {
  static const String id = '/AdminDashboardPage';

  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor, // Consistent background color
      appBar: AppBar(
        title: const Text(
          'ផ្ទាំងគ្រប់គ្រងអ្នកគ្រប់គ្រង', // Admin Dashboard
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.cyan, // Consistent app bar color
        elevation: 0,
        centerTitle: true, // Center the title for a dashboard feel
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 16.0, // Spacing between columns
            mainAxisSpacing: 16.0, // Spacing between rows
            children: <Widget>[
              _buildDashboardCard(
                context,
                // Using a placeholder asset path. Replace 'assets/icons/hotel_icon.png' with your actual asset path.
                // Make sure to add the asset path to your pubspec.yaml file under the 'assets:' section.
                assetPath: 'assets/images/hotel.png',
                title: 'ការគ្រប់គ្រងបន្ទប់', // Room Management
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoomListScreen(),
                    ),
                  );
                },
              ),
              _buildDashboardCard(
                context,
                assetPath: 'assets/images/user.png',
                title: 'ការគ្រប់គ្រងអ្នកប្រើប្រាស់', // User Management
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserManagement(),
                    ),
                  );
                },
              ),
              _buildDashboardCard(
                context,
                assetPath: 'assets/images/order.png',
                title: 'ការគ្រប់គ្រងការកក់', // Booking Management
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(),
                    ),
                  );
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.analytics,
                title: 'របាយការណ៍', // Reports
                onTap: () {
                  // TODO: Navigate to Reports Page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'មុខងាររបាយការណ៍នឹងមកដល់ឆាប់ៗនេះ!',
                      ), // Reports functionality coming soon!
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    IconData? icon, // Made optional
    String? assetPath, // Added optional assetPath
    required String title,
    required VoidCallback onTap,
  }) {
    // Ensure either icon or assetPath is provided, but not both.
    assert(
      icon != null || assetPath != null,
      'Either icon or assetPath must be provided.',
    );
    assert(
      !(icon != null && assetPath != null),
      'Cannot provide both icon and assetPath.',
    );

    Widget cardIcon;
    if (assetPath != null) {
      cardIcon = Image.asset(
        assetPath,
        width: 60, // Consistent size with icons
        height: 60,
        fit: BoxFit.contain, // Adjust fit as needed
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ); // Fallback for asset loading error
        },
      );
    } else {
      cardIcon = Icon(
        icon,
        size: 60, // Larger icon size
        color: AppColor.cyan, // Consistent icon color
      );
    }

    return Card(
      elevation: 5, // Add elevation for a lifted effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners for cards
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              cardIcon, // Use the dynamically determined icon/image
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18, // Larger font size for titles
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor, // Consistent text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
