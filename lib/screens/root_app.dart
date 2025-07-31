import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hotel_booking/models/user_model.dart';
import 'package:hotel_booking/screens/admin/dashboard.dart';
import 'package:hotel_booking/screens/admin/admin_order_screen.dart';

import 'package:hotel_booking/screens/sidebar_screen/room/add_room.dart';
import 'package:hotel_booking/screens/sidebar_screen/room/room_list.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:hotel_booking/auth/login.dart';
import 'package:hotel_booking/screens/profile.dart';
import 'package:hotel_booking/auth/register.dart';
import 'package:hotel_booking/screens/search.dart';
import 'package:hotel_booking/screens/sidebar_screen/user_management.dart';
import 'package:hotel_booking/screens/sidebar_screen/orders_screen.dart';
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

  /// ផ្ទុកវគ្គអ្នកប្រើប្រាស់ពី SharedPreferences ។
  /// កំណត់ _currentUser និង _userEmail ដោយផ្អែកលើទិន្នន័យដែលបានរក្សាទុក។
  Future<void> _loadUserSession() async {
    setState(() {
      _isLoadingUser = true; // ចាប់ផ្តើមផ្ទុក
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
          debugPrint('បរាជ័យក្នុងការឌិកូដ user JSON: $e');
          // ប្រសិនបើការឌិកូដបរាជ័យ ចាត់ទុកថាគ្មានអ្នកប្រើប្រាស់បានចូល
          setState(() {
            _userEmail = null;
            _currentUser = null;
          });
        }
      } else {
        // មិនមានទិន្នន័យអ្នកប្រើប្រាស់ត្រូវបានរកឃើញ
        setState(() {
          _userEmail = null;
          _currentUser = null;
        });
      }
    } catch (e) {
      debugPrint(
        'កំហុសក្នុងការផ្ទុកវគ្គអ្នកប្រើប្រាស់ពី SharedPreferences: $e',
      );
      setState(() {
        _userEmail = null;
        _currentUser = null;
      });
    } finally {
      setState(() {
        _isLoadingUser = false; // បញ្ចប់ការផ្ទុក
      });
    }
  }

  /// ជ្រើសរើសអេក្រង់ដើម្បីបង្ហាញដោយផ្អែកលើ AdminMenuItem ដែលបានជ្រើសរើស។
  void _screenSelector(AdminMenuItem item) {
    setState(() {
      _currentRoute = item.route ?? HomePage.id;
      switch (_currentRoute) {
        case AdminDashboardPage.id:
          _selectedScreen = const AdminDashboardPage();
          break;

        case HomePage.id:
          _selectedScreen = const HomePage();
          break;
        case RoomListScreen.id:
          _selectedScreen = const RoomListScreen();
          break;
        case AddRoomScreen.id:
          _selectedScreen = const AddRoomScreen();
          break;

        case OrdersScreen.id:
          _selectedScreen = const OrdersScreen();
          break;
        case UserManagement.id:
          _selectedScreen = const UserManagement();
          break;
        case AdminOrdersScreen.id:
          _selectedScreen = const AdminOrdersScreen();
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

  /// ចេញពីគណនីអ្នកប្រើប្រាស់ដោយជម្រះទិន្នន័យវគ្គ និងរុករកទៅទំព័រចូល។
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

  /// បង្កើតរូបតំណាងអ្នកប្រើប្រាស់សម្រាប់របារកម្មវិធី។
  /// បង្ហាញរូបភាពប្រវត្តិរូបរបស់អ្នកប្រើប្រាស់ប្រសិនបើមាន បើមិនដូច្នេះទេ រូបតំណាងលំនាំដើម។
  Widget _buildUserAppBarIcon() {
    // ប្រសិនបើ URL រូបភាពប្រវត្តិរូបមាន សូមព្យាយាមផ្ទុកវា។
    if (_currentUser?.profileImage != null &&
        _currentUser!.profileImage!.isNotEmpty) {
      return CircleAvatar(
        radius: 16, // លៃតម្រូវទំហំតាមតម្រូវការសម្រាប់របារកម្មវិធី
        backgroundImage: NetworkImage(_currentUser!.profileImage!),
        backgroundColor: Colors.blueGrey, // ផ្ទៃខាងក្រោយ fallback
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('កំហុសក្នុងការផ្ទុករូបភាពប្រវត្តិរូប: $exception');
          // Fallback ទៅអក្សរផ្ចង់លំនាំដើមប្រសិនបើរូបភាពបរាជ័យក្នុងការផ្ទុក
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
            : null, // គ្មាន child ប្រសិនបើរូបភាពត្រូវបានផ្ទុក
      );
    } else if (_userEmail != null && _userEmail!.isNotEmpty) {
      // ប្រសិនបើគ្មានរូបភាពប្រវត្តិរូប ប៉ុន្តែអ៊ីមែលមាន សូមបង្ហាញអក្សរផ្ចង់
      return CircleAvatar(
        radius: 16,
        backgroundColor: AppColor.labelColor, // ឬពណ៌សមរម្យណាមួយ
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
      // ប្រសិនបើគ្មានអ៊ីមែលអ្នកប្រើប្រាស់ សូមបង្ហាញរូបតំណាងមនុស្សទូទៅសម្រាប់ការចុះឈ្មោះ
      return Icon(Icons.person_add_alt_1, color: AppColor.darker, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    // បង្ហាញសូចនាករផ្ទុកខណៈពេលដែលវគ្គអ្នកប្រើប្រាស់កំពុងត្រូវបានផ្ទុក
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
              icon: _buildUserAppBarIcon(), // ប្រើមុខងារថ្មីនៅទីនេះ
              tooltip: _userEmail != null
                  ? "ប្រវត្តិរូប"
                  : "ចុះឈ្មោះ", // ព័ត៌មានជំនួយឧបករណ៍ដែលពិពណ៌នាកាន់តែច្បាស់
              onPressed: () {
                if (_userEmail != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(email: _userEmail!),
                    ),
                  ).then(
                    (_) => _loadUserSession(),
                  ); // ផ្ទុកវគ្គឡើងវិញបន្ទាប់ពីត្រឡប់ពីប្រវត្តិរូប
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                }
              },
            ),
            IconBox(
              tooltip: 'ស្វែងរក',
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
                  ? 'ផ្ទាំងគ្រប់គ្រងអ្នកគ្រប់គ្រង'
                  : 'ផ្ទាំងគ្រប់គ្រងអ្នកប្រើប្រាស់',
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
                  title: 'ផ្ទាំងគ្រប់គ្រង',
                  route: AdminDashboardPage.id,
                  icon: Icons.home_outlined,
                ),
                AdminMenuItem(
                  title: 'ទំព័រដើម',
                  route: HomePage.id,
                  icon: Icons.home_outlined,
                ),
                AdminMenuItem(
                  title: 'បន្ទប់',
                  icon: Icons.image_outlined,
                  children: [
                    // AdminMenuItem(
                    //   title: 'បន្ថែមបន្ទប់',
                    //   route: AddRoomScreen.id,
                    //   icon: Icons.add,
                    // ),
                    AdminMenuItem(
                      title: 'បន្ថែមបន្ទប់​ & មើលបន្ទប់',
                      route: RoomListScreen.id,
                      icon: Icons.view_list_outlined,
                    ),
                  ],
                ),
                AdminMenuItem(
                  title: 'ការកក់របស់អ្នកគ្រប់គ្រង',
                  route: AdminOrdersScreen.id,
                  icon: Icons.shopping_cart_outlined,
                ),
                AdminMenuItem(
                  title: 'ការគ្រប់គ្រងអ្នកប្រើប្រាស់',
                  route: UserManagement.id,
                  icon: Icons.person_outline,
                ),
                AdminMenuItem(
                  title: 'ចេញពីគណនី',
                  route: 'logout',
                  icon: Icons.logout,
                ),
              ]
            : [
                AdminMenuItem(
                  title: 'ទំព័រដើម',
                  route: HomePage.id,
                  icon: Icons.home_outlined,
                ),
                AdminMenuItem(
                  title: 'ការកក់',
                  route: OrdersScreen.id,
                  icon: Icons.shopping_cart_outlined,
                ),
                // AdminMenuItem(
                //   title: 'ស្វែងរក',
                //   route: '/search',
                //   icon: Icons.search,
                // ),
                AdminMenuItem(
                  title: 'ចេញពីគណនី',
                  route: 'logout',
                  icon: Icons.logout,
                ),
              ],
      ),
    );
  }
}
