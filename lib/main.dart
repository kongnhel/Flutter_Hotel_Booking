import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hotel_booking/auth/login.dart';
import 'package:hotel_booking/config/firebase_options_web.dart';
import 'package:hotel_booking/screens/root_app.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: firebaseWebOptions, // use imported config
    );
  } else {
    await Firebase.initializeApp(); // Android/iOS
  }

  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');

  runApp(MyApp(userEmail: email));
}

class MyApp extends StatelessWidget {
  final String? userEmail;
  const MyApp({super.key, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking kong is cooking',
      theme: ThemeData(primaryColor: AppColor.primary),

      // ប្រសិនបើ email មាន (មាន session អ្នកប្រើប្រាស់) ទៅ RootApp, មិនដំណើរការ login ទៀត
      home: userEmail != null ? const RootApp() : const LoginPage(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const RootApp(),
      },
    );
  }
}
