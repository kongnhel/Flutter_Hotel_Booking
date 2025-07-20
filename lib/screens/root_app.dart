import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hotel_booking/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hotel_booking/screens/login.dart';
import 'package:hotel_booking/screens/profile.dart';
import 'package:hotel_booking/screens/register.dart';
import 'package:hotel_booking/screens/search.dart';
import 'package:hotel_booking/screens/sidebar_screen/banner_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    print('User JSON in SharedPreferences: $userJson'); // Debug print
    final email = prefs.getString('email');

    if (userJson != null && email != null) {
      try {
        final userMap = json.decode(userJson);
        setState(() {
          _userEmail = email;
          _currentUser = UserModel.fromJson(userMap);
          print('Current user role: ${_currentUser?.role}');
        });
      } catch (e) {
        print('Failed to decode user JSON: $e');
        setState(() {
          _userEmail = null;
          _currentUser = null;
        });
      }
    } else {
      setState(() {
        _userEmail = null;
        _currentUser = null;
      });
    }
  }

  void _screenSelector(AdminMenuItem item) {
    setState(() {
      _currentRoute = item.route ?? HomePage.id;
      switch (_currentRoute) {
        case HomePage.id:
          _selectedScreen = const HomePage();
          break;
        case BannerScreen.id:
          _selectedScreen = const BannerScreen();
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

  Widget buildUserIcon() {
    if (_userEmail != null) {
      return ClipOval(
        child: Image.asset(
          "assets/images/profile_emty.png",
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Icon(Icons.person_add_alt_1, color: AppColor.darker, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Loading UI
        ),
      );
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
              icon: buildUserIcon(),
              tooltip: _userEmail ?? "Register",
              onPressed: () {
                if (_userEmail != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(email: _userEmail!),
                    ),
                  );
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
                  title: 'Banner',
                  route: BannerScreen.id,
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
