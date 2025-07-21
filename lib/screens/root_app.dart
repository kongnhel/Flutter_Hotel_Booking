import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hotel_booking/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hotel_booking/auth/login.dart';
import 'package:hotel_booking/screens/profile.dart';
import 'package:hotel_booking/auth/register.dart';
import 'package:hotel_booking/screens/search.dart';
import 'package:hotel_booking/screens/sidebar_screen/room_screen.dart';
import 'package:hotel_booking/screens/sidebar_screen/buyers_screen.dart';
import 'package:hotel_booking/screens/sidebar_screen/categories_screen.dart';
import 'package:hotel_booking/screens/sidebar_screen/orders_screen.dart';
import 'package:hotel_booking/screens/sidebar_screen/products_screen.dart';
import 'package:hotel_booking/screens/sidebar_screen/vendors_screen.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:hotel_booking/widgets/icon_box.dart';
import 'home.dart';

class RootApp extends StatefulWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  Widget _selectedScreen = const HomePage();
  String _currentRoute = HomePage.id;
  UserModel? _currentUser;
  String? _userEmail;
  bool _isLoadingUser = true; // New state to track user loading

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  /// Loads the user session from SharedPreferences.
  /// Sets _currentUser and _userEmail based on stored data.
  Future<void> _loadUserSession() async {
    setState(() {
      _isLoadingUser = true; // Start loading
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final email = prefs.getString('email');

      if (userJson != null && email != null) {
        try {
          final userMap = json.decode(userJson);
          setState(() {
            _userEmail = email;
            _currentUser = UserModel.fromJson(userMap);
          });
        } catch (e) {
          debugPrint('Failed to decode user JSON: $e');
          // If decoding fails, treat as no user logged in
          setState(() {
            _userEmail = null;
            _currentUser = null;
          });
        }
      } else {
        // No user data found
        setState(() {
          _userEmail = null;
          _currentUser = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading user session from SharedPreferences: $e');
      setState(() {
        _userEmail = null;
        _currentUser = null;
      });
    } finally {
      setState(() {
        _isLoadingUser = false; // End loading
      });
    }
  }

  /// Selects the screen to display based on the selected AdminMenuItem.
  void _screenSelector(AdminMenuItem item) {
    setState(() {
      _currentRoute = item.route ?? HomePage.id;
      switch (_currentRoute) {
        case HomePage.id:
          _selectedScreen = const HomePage();
          break;
        case RoomAdminScreen.id:
          _selectedScreen = const RoomAdminScreen();
          break;
        case ProductsScreen.id:
          _selectedScreen = const ProductsScreen();
          break;
        case CategoriesScreen.id:
          _selectedScreen = const CategoriesScreen();
          break;
        case OrdersScreen.id:
          _selectedScreen = const OrdersScreen();
          break;
        case BuyersScreen.id:
          _selectedScreen = const BuyersScreen();
          break;
        case VendorsScreen.id:
          _selectedScreen = const VendorsScreen();
          break;
        case '/search':
          _selectedScreen = const SearchPage();
          break;
        case 'logout':
          _logout();
          break;
        default:
          _selectedScreen = const HomePage();
      }
    });
  }

  /// Logs out the user by clearing session data and navigating to the login page.
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('email');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  /// Builds the user icon for the app bar.
  /// Displays the user's profile image if available, otherwise a default avatar.
  Widget _buildUserAppBarIcon() {
    // If a profile image URL exists, try to load it.
    if (_currentUser?.profileImage != null &&
        _currentUser!.profileImage!.isNotEmpty) {
      return CircleAvatar(
        radius: 16, // Adjust size as needed for app bar
        backgroundImage: NetworkImage(_currentUser!.profileImage!),
        backgroundColor: Colors.blueGrey, // Fallback background
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading profile image: $exception');
          // Fallback to default initial if image fails to load
        },
        child:
            _currentUser?.profileImage == null ||
                _currentUser!.profileImage!.isEmpty
            ? Text(
                _userEmail?.isNotEmpty == true
                    ? _userEmail![0].toUpperCase()
                    : "?",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : null, // No child if image is loaded
      );
    } else if (_userEmail != null && _userEmail!.isNotEmpty) {
      // If no profile image but email exists, show initial
      return CircleAvatar(
        radius: 16,
        backgroundColor: AppColor.labelColor, // Or any suitable color
        child: Text(
          _userEmail![0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // If no user email, show a generic person icon for registration
      return Icon(Icons.person_add_alt_1, color: AppColor.darker, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while user session is being loaded
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            IconBox(
              onPressed: () {},
              tooltip: '',
              child: Image.asset(
                "assets/images/logo_2.png",
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              "Hotel Booking",
              style: TextStyle(color: AppColor.darker, fontSize: 13),
            ),
            const Spacer(),
            IconButton(
              icon: _buildUserAppBarIcon(), // Use the new function here
              tooltip: _userEmail != null
                  ? "Profile"
                  : "Register", // More descriptive tooltip
              onPressed: () {
                if (_userEmail != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(email: _userEmail!),
                    ),
                  ).then(
                    (_) => _loadUserSession(),
                  ); // Reload session after returning from profile
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                }
              },
            ),
            IconBox(
              tooltip: 'Search',
              onPressed: () {},
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
              },
              child: SvgPicture.asset(
                "assets/icons/search.svg",
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _selectedScreen,
      sideBar: SideBar(
        header: Container(
          height: 50,
          width: double.infinity,
          color: const Color.fromARGB(106, 60, 117, 174),
          child: Center(
            child: Text(
              _currentUser?.role == 'admin'
                  ? 'Admin Dashboard'
                  : 'User Dashboard',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        onSelected: _screenSelector,
        selectedRoute: _currentRoute,
        items: _currentUser?.role == 'admin'
            ? [
                AdminMenuItem(
                  title: 'Home',
                  route: HomePage.id,
                  icon: Icons.home_outlined,
                ),
                AdminMenuItem(
                  title: 'Room',
                  route: RoomAdminScreen.id,
                  icon: Icons.image_outlined,
                ),
                AdminMenuItem(
                  title: 'Products',
                  route: ProductsScreen.id,
                  icon: Icons.production_quantity_limits_outlined,
                ),
                AdminMenuItem(
                  title: 'Categories',
                  route: CategoriesScreen.id,
                  icon: Icons.category_outlined,
                ),
                AdminMenuItem(
                  title: 'Orders',
                  route: OrdersScreen.id,
                  icon: Icons.shopping_cart_outlined,
                ),
                AdminMenuItem(
                  title: 'Buyers',
                  route: BuyersScreen.id,
                  icon: Icons.person_outline,
                ),
                AdminMenuItem(
                  title: 'Vendors',
                  route: VendorsScreen.id,
                  icon: Icons.store_outlined,
                ),
                AdminMenuItem(
                  title: 'Logout',
                  route: 'logout',
                  icon: Icons.logout,
                ),
              ]
            : [
                AdminMenuItem(
                  title: 'Home',
                  route: HomePage.id,
                  icon: Icons.home_outlined,
                ),
                AdminMenuItem(
                  title: 'Search',
                  route: '/search',
                  icon: Icons.search,
                ),
                AdminMenuItem(
                  title: 'Logout',
                  route: 'logout',
                  icon: Icons.logout,
                ),
              ],
      ),
    );
  }
}
