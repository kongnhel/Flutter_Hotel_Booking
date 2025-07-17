import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotel_booking/theme/color.dart';

class ProfilePage extends StatefulWidget {
  final String email;

  const ProfilePage({Key? key, required this.email}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // You can replace this with real data fetching or editing later
  String? _profileImage; // null means no image
  String? _phone = "+12 345 6789";

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email'); // Clear login

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    ); // Go to login immediately
  }

  void _showConfirmLogout() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        message: const Text("Would you like to log out?"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: Text(
              "Log Out",
              style: TextStyle(color: AppColor.actionColor),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
              color: AppColor.textColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Uncomment below if you want to add edit icon later
        // IconButton(
        //   icon: Icon(Icons.edit, color: AppColor.textColor),
        //   onPressed: () {},
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
            _phone ?? "+12 345 6789",
            style: TextStyle(color: AppColor.labelColor, fontSize: 14),
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
      backgroundColor: AppColor.appBgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColor.appBarColor,
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
                leadingIconColor: AppColor.orange,
                onTap: () {
                  // TODO: Navigate to general settings page
                },
              ),
              _buildSettingItem(
                title: "Bookings",
                leadingIcon: Icons.bookmark_border,
                leadingIconColor: AppColor.blue,
                onTap: () {
                  // TODO: Navigate to bookings page
                },
              ),
              _buildSettingItem(
                title: "Favorites",
                leadingIcon: Icons.favorite,
                leadingIconColor: AppColor.red,
                onTap: () {
                  // TODO: Navigate to favorites page
                },
              ),
              _buildSettingItem(
                title: "Privacy",
                leadingIcon: Icons.privacy_tip_outlined,
                leadingIconColor: AppColor.green,
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
