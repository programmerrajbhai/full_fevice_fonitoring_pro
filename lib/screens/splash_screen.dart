import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'main_layout.dart'; // সরাসরি মেইন লেআউটে যাবে

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // 3 সেকেন্ড হ্যাকার এনিমেশন দেখাবে
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // লগইন চেক ছাড়াই সরাসরি ড্যাশবোর্ডে
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout())
      );
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(color: kPrimaryColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 5)
                  ]
              ),
              child: const Icon(Icons.security, size: 80, color: kPrimaryColor),
            ),
            const SizedBox(height: 30),
            const Text(
              "SYSTEM INITIALIZING...",
              style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: kPrimaryColor),
          ],
        ),
      ),
    );
  }
}