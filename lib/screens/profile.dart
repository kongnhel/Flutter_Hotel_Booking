import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Unified import for Material and Cupertino widgets
import 'package:hotel_booking/models/user_model.dart';
import 'package:hotel_booking/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotel_booking/theme/color.dart';

class ProfilePage extends StatefulWidget {
  final String email;

  const ProfilePage({Key? key, required this.email}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _currentUser;

  // You can replace this with real data fetching or editing later
  String? _profileImage; // null means no image
  String _phone = "+12 345 6789"; // Made non-nullable with default

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    // print('User JSON in SharedPreferences: $userJson'); // Debug print - uncomment if needed

    if (userJson != null) {
      try {
        final userMap = json.decode(userJson);
        setState(() {
          _currentUser = UserModel.fromJson(userMap);
          // print('Current user role: ${_currentUser?.role}'); // Debug print - uncomment if needed
        });
      } catch (e) {
        // Log the error for debugging, but don't halt the app
        debugPrint('Failed to decode user JSON: $e');
        setState(() {
          _currentUser = null;
        });
      }
    } else {
      setState(() {
        _currentUser = null;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('user');

    if (!mounted)
      return; // Check if the widget is still mounted before navigation

    // Use pushAndRemoveUntil for a clean navigation stack after logout
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false, // This predicate removes all previous routes
    );
  }

  void _showConfirmLogout() {
    showCupertinoModalPopup<void>(
      // Specify return type for clarity
      context: context,
      builder: (context) => Material(
        // Wrap CupertinoActionSheet in Material to avoid specific render issues
        color: Colors.transparent, // Make Material transparent
        child: CupertinoActionSheet(
          message: const Text("Would you like to log out?"),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the action sheet
                _logout();
              },
              isDestructiveAction:
                  true, // Indicate a destructive action (often red text)
              child: Text(
                "Log Out",
                style: TextStyle(
                  color: AppColor.actionColor,
                ), // Ensure AppColor.actionColor is defined
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the action sheet
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "Profile",
            style: TextStyle(
              color: AppColor.textColor, // Ensure AppColor.textColor is defined
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Moved the Dashboard text to the right for better alignment with the original code's intention
        // and to allow for potential future edit icon placement on the far right.
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            // Wrap with Container or Chip for a background, if desired
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color:
                  AppColor.labelColor, // Example background color for the badge
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentUser?.role == 'admin' ? 'Admin' : 'User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14, // Slightly smaller for a badge-like appearance
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Uncomment below if you want to add edit icon later
        // IconButton(
        //   icon: Icon(Icons.edit, color: AppColor.textColor),
        //   onPressed: () {
        //     // TODO: Implement edit profile functionality
        //   },
        // ),
      ],
    );
  }

  Widget _buildProfile() {
    final hasImage = _profileImage != null && _profileImage!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 30),
      child: Column(
        children: <Widget>[
          hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    _profileImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueGrey,
                  child: Text(
                    widget.email.isNotEmpty
                        ? widget.email[0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          const SizedBox(height: 12),
          Text(
            widget.email,
            style: TextStyle(
              color: AppColor.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _phone, // _phone is now non-nullable
            style: TextStyle(
              color: AppColor.labelColor,
              fontSize: 14,
            ), // Ensure AppColor.labelColor is defined
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData leadingIcon,
    required Color leadingIconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(leadingIcon, color: leadingIconColor),
      title: Text(
        title,
        style: TextStyle(color: AppColor.textColor, fontSize: 16),
      ),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColor.appBgColor, // Ensure AppColor.appBgColor is defined
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor:
                AppColor.appBarColor, // Ensure AppColor.appBarColor is defined
            pinned: true,
            snap: true,
            floating: true,
            title: _buildAppBar(),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildProfile(),
              const SizedBox(height: 20),
              _buildSettingItem(
                title: "General Setting",
                leadingIcon: Icons.settings,
                leadingIconColor:
                    AppColor.orange, // Ensure AppColor.orange is defined
                onTap: () {
                  // TODO: Navigate to general settings page
                },
              ),
              _buildSettingItem(
                title: "Bookings",
                leadingIcon: Icons.bookmark_border,
                leadingIconColor:
                    AppColor.blue, // Ensure AppColor.blue is defined
                onTap: () {
                  // TODO: Navigate to bookings page
                },
              ),
              _buildSettingItem(
                title: "Favorites",
                leadingIcon: Icons.favorite,
                leadingIconColor:
                    AppColor.red, // Ensure AppColor.red is defined
                onTap: () {
                  // TODO: Navigate to favorites page
                },
              ),
              _buildSettingItem(
                title: "Privacy",
                leadingIcon: Icons.privacy_tip_outlined,
                leadingIconColor:
                    AppColor.green, // Ensure AppColor.green is defined
                onTap: () {
                  // TODO: Navigate to privacy settings page
                },
              ),
              _buildSettingItem(
                title: "Log Out",
                leadingIcon: Icons.logout_outlined,
                leadingIconColor: Colors.grey.shade400,
                onTap: _showConfirmLogout,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
