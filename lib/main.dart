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
      title: 'Device Monitor Pro',
      theme: ThemeData.dark(),
      home: const SplashScreen(), // এখান থেকে শুরু হবে
    );
  }
}