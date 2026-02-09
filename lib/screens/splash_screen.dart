import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'login_screen.dart';
import 'main_layout.dart'; // ড্যাশবোর্ড বা মেইন লেআউট

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // লগইন স্ট্যাটাস চেক ফাংশন
  void _checkLoginStatus() async {
    // ২ সেকেন্ড হ্যাকার ভাইব দেখানোর জন্য ডিলে
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (mounted) {
      if (isLoggedIn) {
        // আগে লগইন করা থাকলে সরাসরি মেইন লেআউটে যাবে
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout())
        );
      } else {
        // লগইন না থাকলে লগইন পেজে যাবে
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // হ্যাকার আইকন গ্লো ইফেক্ট সহ
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor, width: 3),
                  boxShadow: [
                    BoxShadow(color: kPrimaryColor.withOpacity(0.5), blurRadius: 40, spreadRadius: 5)
                  ]
              ),
              child: const Icon(Icons.bug_report, size: 80, color: kPrimaryColor),
            ),
            const SizedBox(height: 30),
            const Text(
              "INITIALIZING SYSTEM...",
              style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFF111111),
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "v1.0.0 [SECURE]",
              style: TextStyle(color: Colors.grey, fontFamily: 'Courier', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}