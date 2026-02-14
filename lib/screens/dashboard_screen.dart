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

  String statusText = "System: Online... Waiting for Target...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // হ্যাকার স্ট্যাটাস আপডেট লজিক (Bangla & English Mix)
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          List<String> logs = [
            "Scanning Ports... [পোর্ট স্ক্যানিং চলছে]",
            "Encrypting Connection... [কানেকশন এনক্রিপ্ট করা হচ্ছে]",
            "Masking IP Address: 192.168.X.X",
            "System Secure... [সিস্টেম নিরাপদ]",
            "Waiting for Input... [ইনপুটের অপেক্ষায়]",
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
    // ⚠️ Validation: ইনপুট ফিল্ড খালি থাকলে কাজ করবে না
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ $emptyWarning"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ১. প্রথমে লোডিং দেখাবে
    await _showLoading("System Initializing... [সিস্টেম চালু হচ্ছে]");

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      _showLoginRequiredDialog();
    } else {
      // ✅ নতুন স্ক্রিনে ইমেজ পাথ পাঠানো হচ্ছে
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
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.red),
        title: const Text("ACCESS DENIED", style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        content: const Text("সিস্টেম ব্যবহার করতে লগইন প্রয়োজন।", style: TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("LOGIN NOW", style: TextStyle(color: Colors.white)),
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
        title: const Text("DEVICE MONITORING PRO", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
        backgroundColor: Colors.black,
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: kPrimaryColor, height: 1.0)),
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/images2.jpg"), // Main Background
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.darken),
                fit: BoxFit.cover,
              ),
            ),
            child: GridPaper(color: kPrimaryColor.withOpacity(0.1), interval: 50, divisions: 1, subdivisions: 1),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- STATUS BAR ---
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.black, border: Border.all(color: kPrimaryColor)),
                  child: Row(children: [
                    const Icon(Icons.terminal, color: kPrimaryColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(statusText, style: const TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ]),
                ),
                const SizedBox(height: 25),
                const Center(child: Icon(Icons.security, size: 70, color: kPrimaryColor)),
                const SizedBox(height: 30),

                // --- 1. TARGET CONNECTION SECTION ---
                _buildHackerSection(
                  title: "TARGET CONNECTION [টার্গেট কানেকশন]",
                  color: kPrimaryColor,
                  child: Column(
                    children: [
                      HackerInput(
                          hintText: "Enter Number (e.g. +88017...)", // ইউনিভার্সাল ফরম্যাট হিন্ট
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_android
                      ),
                      const SizedBox(height: 10),
                      const Text(
                          "> Establishing connection via Global Network...",
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Courier')
                      ),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "ESTABLISH CONNECTION",
                        color: kRedButtonColor,
                        onPressed: () => _handleAction(
                            "https://storage.googleapis.com/support-forums-api/attachment/message-243247620-13466872279101780486.jpg",
                            _phoneController,
                            "Target number is required! [টার্গেট নম্বর দিন]"
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- 2. FACEBOOK HACK SECTION ---
                _buildHackerSection(
                  title: "FACEBOOK ACCESS [ফেসবুক অ্যাক্সেস]",
                  color: kBlueButtonColor,
                  child: Column(
                    children: [
                      HackerInput(
                          hintText: "Profile / Page Link URL",
                          controller: _facebookController,
                          icon: Icons.link
                      ),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "START BRUTE FORCE",
                        color: kBlueButtonColor,
                        onPressed: () => _handleAction(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGfaa2IlatyXU2GvnAgEya0cqxcxnoT-nB-Q&s",
                            _facebookController,
                            "Profile link is required! [প্রোফাইল লিংক দিন]"
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- 3. ACCOUNT DISABLE SECTION ---
                _buildHackerSection(
                  title: "ACCOUNT REMOVAL [অ্যাকাউন্ট ডিজেবল]",
                  color: const Color(0xFFD32F2F),
                  child: Column(
                    children: [
                      HackerInput(
                          hintText: "Target ID / Evidence Link",
                          controller: _disableController,
                          icon: Icons.block
                      ),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "INITIATE TAKEDOWN",
                        color: const Color(0xFFD32F2F),
                        onPressed: () => _handleAction(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGfaa2IlatyXU2GvnAgEya0cqxcxnoT-nB-Q&s",
                            _disableController,
                            "Target info required! [টার্গেট তথ্য দিন]"
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text("SERVER LOAD: 78% | NODES: ACTIVE", textAlign: TextAlign.center, style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 12, letterSpacing: 1.5)),
                const SizedBox(height: 5),
                const Text("[||||||||||||||------]", textAlign: TextAlign.center, style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 12)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackerSection({required String title, required Color color, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: color.withOpacity(0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("[$title]", style: TextStyle(color: color, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 13)),
                Icon(Icons.lock_open, color: color, size: 16),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(15.0), child: child),
        ],
      ),
    );
  }
}