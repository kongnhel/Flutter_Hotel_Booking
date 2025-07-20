import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/login.dart';
import 'package:hotel_booking/screens/root_app.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // កំណត់ Firebase config សម្រាប់ Web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBNIMsW9oS44Et4src9bMLo_49YcJ6vm_M",
        authDomain: "hotelbooking-d4c6d.firebaseapp.com",
        projectId: "hotelbooking-d4c6d",
        storageBucket: "hotelbooking-d4c6d.firebasestorage.app",
        messagingSenderId: "217330523535",
        appId: "1:217330523535:web:e1c9b15b7ecc4436d83ffa",
      ),
    );
  } else {
    // សម្រាប់ Android/iOS ដំណើរការ default initialize
    await Firebase.initializeApp();
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
      title: 'Hotel Booking',
      theme: ThemeData(primaryColor: AppColor.primary),

      home: userEmail != null ? const RootApp() : const LoginPage(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const RootApp(),
      },
    );
  }
}
