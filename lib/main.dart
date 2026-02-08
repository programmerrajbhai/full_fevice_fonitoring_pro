import 'package:flutter/material.dart';
import 'package:full_fevice_fonitoring_pro/screens/main_layout.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hacker App',
      theme: ThemeData.dark(), // ডিফল্ট ডার্ক থিম
// lib/main.dart
      home: const MainLayout(),
    );
  }
}