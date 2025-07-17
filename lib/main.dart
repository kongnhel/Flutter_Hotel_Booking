import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/login.dart';
import 'package:hotel_booking/screens/register.dart';
import 'package:hotel_booking/screens/root_app.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ main() ត្រូវនៅខាងក្រៅ class MyApp
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ត្រូវប្រើសម្រាប់ async ก่อน runApp
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  runApp(MyApp(userEmail: email));
}

class MyApp extends StatelessWidget {
  final String? userEmail;
  const MyApp({super.key, this.userEmail});

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking',
      theme: ThemeData(primaryColor: AppColor.primary),
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.data == true) {
              return RootApp(initialEmail: userEmail);
            } else {
              return const RegisterPage();
            }
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const RootApp(),
      },
    );
  }
}
