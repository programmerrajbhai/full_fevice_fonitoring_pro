import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../widgets/hacker_drawer.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
import '../widgets/hacker_loading.dart';
import 'login_screen.dart';
import 'input_token_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool? isPremium;
  const DashboardScreen({super.key, this.isPremium});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- Controllers for Inputs ---
  final TextEditingController _deviceController = TextEditingController();
  final TextEditingController _messengerController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  String statusText = "System Status: Online | Ready";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
    });
  }

  @override
  void dispose() {
    _deviceController.dispose();
    _messengerController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  // --- Clean Disclaimer Dialog ---
  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: kPrimaryColor),
            SizedBox(width: 10),
            Text("NOTICE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
            "This application provides standard utilities and educational tools. It complies with all privacy and security guidelines. No unauthorized access or operations are performed.",
            style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("CONTINUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Loading Animation ---
  Future<void> _showLoading() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const HackerLoading(statusText: "Processing Request...", message: ''),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  // --- MAIN ACTION BUTTON LOGIC ---
  void _handleAction(TextEditingController controller, String emptyWarning) async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emptyWarning),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _showLoading();

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      _showLoginRequiredDialog();
    } else {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InputTokenScreen(backgroundImage: "assets/images/images2.jpg"),
          ),
        );
      }
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Authentication Required", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Please login to access these tools.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HackerDrawer(),
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Security & Activity Tools", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
        backgroundColor: kCardColor,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CLEAN STATUS BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
                  ]
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(statusText, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ]),
            ),

            const SizedBox(height: 30),

            // --- 1. DEVICE OVERVIEW ---
            _buildToolSection(
              title: "Device Overview",
              subtitle: "Manage device settings via ID/Number",
              icon: Icons.smartphone,
              child: Column(
                children: [
                  HackerInput(
                      hintText: "Enter Device ID or Number...",
                      controller: _deviceController,
                      keyboardType: TextInputType.text,
                      icon: Icons.devices
                  ),
                  const SizedBox(height: 12),
                  HackerButton(
                    text: "Open Device Manager",
                    color: kPrimaryColor,
                    onPressed: () => _handleAction(_deviceController, "Please enter a valid Device ID!"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. MESSENGER TOOLS ---
            _buildToolSection(
              title: "Messenger Tools",
              subtitle: "Manage and analyze communication data",
              icon: Icons.message_outlined,
              child: Column(
                children: [
                  HackerInput(
                      hintText: "Enter Account Reference...",
                      controller: _messengerController,
                      icon: Icons.chat
                  ),
                  const SizedBox(height: 12),
                  HackerButton(
                    text: "Access Tools",
                    color: kPrimaryColor,
                    onPressed: () => _handleAction(_messengerController, "Please enter account reference!"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. FACEBOOK TOOLS ---
            _buildToolSection(
              title: "Facebook Tools",
              subtitle: "Profile utilities and activity management",
              icon: Icons.public,
              child: Column(
                children: [
                  HackerInput(
                      hintText: "Enter Profile Link...",
                      controller: _facebookController,
                      icon: Icons.link
                  ),
                  const SizedBox(height: 12),
                  HackerButton(
                    text: "Open Utilities",
                    color: kPrimaryColor,
                    onPressed: () => _handleAction(_facebookController, "Please enter a profile link!"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text("VERSION 3.0 | SECURE CONNECTION", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- CLEAN SECTION WIDGET ---
  Widget _buildToolSection({required String title, required String subtitle, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Icon(icon, color: kPrimaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: child),
        ],
      ),
    );
  }
}