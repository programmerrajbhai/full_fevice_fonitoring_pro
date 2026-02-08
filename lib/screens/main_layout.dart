import 'package:flutter/material.dart';
import '../constants.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0; // 0 = Home, 1 = Profile

  // সাবস্ক্রিপশন স্টেট এখানে ম্যানেজ করা হচ্ছে যাতে দুই পেজেই এফেক্ট পড়ে
  bool isPremiumUser = false;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // সাবস্ক্রিপশন আপডেট করার ফাংশন
  void _updateSubscriptionStatus(bool status) {
    setState(() {
      isPremiumUser = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    // স্ক্রিন লিস্ট (Subscription Status পাস করা হচ্ছে)
    final List<Widget> screens = [
      DashboardScreen(isPremium: isPremiumUser),
      ProfileScreen(isPremium: isPremiumUser, onUpgrade: () => _updateSubscriptionStatus(true)),
    ];

    return Scaffold(
      backgroundColor: Colors.black,

      // বডি (ড্যাশবোর্ড বা প্রোফাইল)
      body: screens[_currentIndex],

      // --- HACKER STYLE BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: const Border(top: BorderSide(color: kPrimaryColor, width: 2)), // উপরের নিয়ন বর্ডার
          boxShadow: [
            BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey[700],
          selectedLabelStyle: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Courier'),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize),
              label: 'Home', // Home
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_moon),
              label: 'Profile', // Profile
            ),
          ],
        ),
      ),
    );
  }
}