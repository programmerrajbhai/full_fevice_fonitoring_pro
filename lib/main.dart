import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // ইম্পোর্ট করুন

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cyber Security Simulator', // নাম পরিবর্তন করা হয়েছে
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}




