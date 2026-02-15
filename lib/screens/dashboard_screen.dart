import 'dart:async';
import 'dart:math';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _disableController = TextEditingController();

  String statusText = "System: Online... Ready for Action...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Dynamic Status Updates
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          List<String> logs = [
            "Scanning Network... [নেটওয়ার্ক স্ক্যান করা হচ্ছে]",
            "Connection Secure... [কানেকশন নিরাপদ]",
            "Searching Target... [টার্গেট খোঁজা হচ্ছে]",
            "Server: Active... [সার্ভার চালু আছে]",
            "Ready to Attack... [অ্যাকশনের জন্য প্রস্তুত]",
          ];
          statusText = logs[Random().nextInt(logs.length)];
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _facebookController.dispose();
    _disableController.dispose();
    super.dispose();
  }

  // --- Loading Animation ---
  Future<void> _showLoading(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HackerLoading(statusText: message, message: '',),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  // --- MAIN ACTION BUTTON LOGIC ---
  void _handleAction(String imagePath, TextEditingController controller, String emptyWarning) async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ $emptyWarning"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _showLoading("Processing Request... [প্রসেসিং চলছে]");

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      _showLoginRequiredDialog();
    } else {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InputTokenScreen(backgroundImage: imagePath),
          ),
        );
      }
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
        title: const Text("ACCESS RESTRICTED", style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        content: const Text("Please login to use this tool.\n(এই টুলস ব্যবহার করতে লগইন করুন)", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HackerDrawer(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Full Device Monitoring Pro", style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.5, color: kPrimaryColor)),
        backgroundColor: Colors.black,
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: kPrimaryColor.withOpacity(0.5), height: 1.0)),
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/images2.jpg"),
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.darken),
                fit: BoxFit.cover,
              ),
            ),
            child: GridPaper(color: kPrimaryColor.withOpacity(0.05), interval: 50, divisions: 1, subdivisions: 1),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- STATUS BAR ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Row(children: [
                    const Icon(Icons.terminal, color: kPrimaryColor, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(statusText, style: const TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  ]),
                ),

                const SizedBox(height: 20),
                const Center(child: Icon(Icons.shield_moon, size: 60, color: kPrimaryColor)),
                const SizedBox(height: 30),

                // --- 1. TARGET CONNECTION ---
                _buildHackerSection(
                  title: "DEVICE CONNECTION",
                  subtitle: "Connect via Phone Number",
                  color: kPrimaryColor,
                  child: Column(
                    children: [
                      HackerInput(
                          hintText: "Enter Phone Number...",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_iphone
                      ),
                      const SizedBox(height: 12),
                      HackerButton(
                        text: "CONNECT DEVICE",
                        color: kRedButtonColor,
                        onPressed: () => _handleAction(
                            "https://storage.googleapis.com/support-forums-api/attachment/message-243247620-13466872279101780486.jpg",
                            _phoneController,
                            "Please enter a phone number!"
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- 2. FACEBOOK ACCESS ---
                _buildHackerSection(
                  title: "FACEBOOK ACCESS",
                  subtitle: "Recover or Access Account",
                  color: kBlueButtonColor,
                  child: Column(
                    children: [
                      HackerInput(
                          hintText: "Enter Profile Link...",
                          controller: _facebookController,
                          icon: Icons.facebook
                      ),
                      const SizedBox(height: 12),
                      HackerButton(
                        text: "START PROCESS",
                        color: kBlueButtonColor,
                        onPressed: () => _handleAction(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGfaa2IlatyXU2GvnAgEya0cqxcxnoT-nB-Q&s",
                            _facebookController,
                            "Please enter a profile link!"
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- 3. ACCOUNT DISABLE ---
                _buildHackerSection(
                  title: "ACCOUNT REMOVAL",
                  subtitle: "Report or Disable Account",
                  color: const Color(0xFFD32F2F),
                  child: Column(
                    children: [
                      HackerInput(
                          hintText: "Target ID Link...",
                          controller: _disableController,
                          icon: Icons.block
                      ),
                      const SizedBox(height: 12),
                      HackerButton(
                        text: "SUBMIT REPORT",
                        color: const Color(0xFFD32F2F),
                        onPressed: () => _handleAction(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGfaa2IlatyXU2GvnAgEya0cqxcxnoT-nB-Q&s",
                            _disableController,
                            "Please enter target ID link!"
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text("SYSTEM STATUS: STABLE | V3.0", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontFamily: 'Courier', fontSize: 10)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackerSection({required String title, required String subtitle, required Color color, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: color, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
                Icon(Icons.lock_open, color: color.withOpacity(0.7), size: 18),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(15.0), child: child),
        ],
      ),
    );
  }
}