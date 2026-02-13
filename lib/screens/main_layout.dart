import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // প্রিফারেন্স চেক করার জন্য
import '../constants.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  // ইউজার স্ট্যাটাস লোড করা
  void _loadUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPremiumUser = prefs.getBool('is_subscribed') ?? false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _updateSubscriptionStatus(bool status) {
    setState(() {
      isPremiumUser = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(isPremium: isPremiumUser),
      ProfileScreen(isPremium: isPremiumUser, onUpgrade: () => _updateSubscriptionStatus(true)),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: const Border(top: BorderSide(color: kPrimaryColor, width: 2)),
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
              label: 'TERMINAL',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_moon),
              label: 'IDENTITY',
            ),
          ],
        ),
      ),
    );
  }
}