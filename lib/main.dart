import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/root_app.dart'; // This import is crucial
import 'package:hotel_booking/theme/color.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking',
      theme: ThemeData(primaryColor: AppColor.primary),
      home: const RootApp(), // Here's where RootApp is used
    );
  }
}
