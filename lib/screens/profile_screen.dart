import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_button.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'subscription_screen.dart'; // সাবস্ক্রিপশন স্ক্রিন ইম্পোর্ট

class ProfileScreen extends StatefulWidget {
  final bool isPremium;
  final VoidCallback onUpgrade;

  const ProfileScreen({
    super.key,
    required this.isPremium,
    required this.onUpgrade,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "LOADING...";
  String email = "LOADING...";
  String joinDate = "LOADING...";
  String planType = "Free"; // নতুন ভেরিয়েবল
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    final data = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        if (data['success']) {
          username = data['username'].toString().toUpperCase();
          email = data['email'];
          joinDate = data['joined_date'];
          planType = data['plan_type'] ?? "Free"; // প্ল্যান ডাটা সেট করা হলো
        } else {
          username = "UNKNOWN";
        }
        isLoading = false;
      });
    }
  }

  // --- NEW UPGRADE LOGIC ---
  void _navigateToSubscription() async {
    // সরাসরি সাবস্ক্রিপশন পেজে নিয়ে যাবে
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );

    // যদি পেমেন্ট সফল হয় এবং ফিরে আসে
    if (result == true) {
      widget.onUpgrade(); // মেইন লেআউট আপডেট
      _fetchProfileData(); // প্রোফাইল ডাটা রিফ্রেশ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated! Welcome to VIP.")),
      );
    }
  }

  // --- LOGOUT FUNCTION ---
  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.red),
        title: const Text(
          "TERMINATE SESSION?",
          style: TextStyle(color: Colors.red, fontFamily: 'Courier'),
        ),
        content: const Text(
          "Are you sure you want to disconnect from the server?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text(
              "DISCONNECT",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVip = widget.isPremium;
    final Color statusColor = isVip ? kPrimaryColor : Colors.red;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "USER_DOSSIER",
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kPrimaryColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: statusColor, height: 1.0),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- AVATAR SECTION ---
            _buildAvatarSection(statusColor, isVip),

            const SizedBox(height: 30),

            // --- INFO CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: statusColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  _buildRow("IDENTITY", username),
                  const Divider(color: Colors.white10),
                  _buildRow("EMAIL", email),
                  const Divider(color: Colors.white10),
                  _buildRow("ESTABLISHED", joinDate),
                  const Divider(color: Colors.white10),
                  // নতুন প্ল্যান ইনফো
                  _buildRow("CURRENT PLAN", isVip ? planType : "Free Tier"),
                  const Divider(color: Colors.white10),
                  _buildRow(
                    "ACCESS LEVEL",
                    isVip ? "ADMIN (VIP)" : "RESTRICTED",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- MAIN ACTION BUTTON ---
            if (!isVip) ...[
              const Text(
                "UPGRADE REQUIRED FOR FULL ACCESS",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(height: 8),
              HackerButton(
                text: "UNLOCK PREMIUM (PACKAGES)", // টেক্সট পরিবর্তন
                color: kPrimaryColor,
                onPressed: _navigateToSubscription, // নতুন ফাংশন কল
              ),
            ] else ...[
              HackerButton(
                text: "VIEW ACCESS KEYS",
                color: kBlueButtonColor,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("KEY: ADMIN_X_999")),
                  );
                },
              ),
            ],

            const SizedBox(height: 15),

            // --- LOGOUT BUTTON ---
            HackerButton(
              text: "DISCONNECT SYSTEM",
              color: Colors.red[900]!,
              onPressed: _handleLogout,
            ),

            const SizedBox(height: 20),
            const Text(
              "SESSION ID: 8X99-AF22",
              style: TextStyle(color: Colors.white10, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(Color color, bool isVip) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1A1A1A),
            child: Icon(Icons.person, size: 50, color: Colors.white70),
          ),
          if (isVip)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: color),
                ),
                child: Icon(Icons.verified_user, color: color, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}