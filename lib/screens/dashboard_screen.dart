import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
import 'subscription_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool isSubscribed = false;
  final TextEditingController keyController = TextEditingController();

  // Terminal Typing Effect Variables
  String statusText = "SYSTEM: ONLINE... WAITING FOR TARGET...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Random Status Update for Hacker Vibe
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        List<String> logs = [
          "SCANNING PORTS...",
          "ENCRYPTING CONNECTION...",
          "IP MASKED: 192.168.X.X",
          "SYSTEM SECURE...",
          "WAITING FOR INPUT..."
        ];
        statusText = logs[Random().nextInt(logs.length)];
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: kPrimaryColor, width: 2),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: kPrimaryColor),
              SizedBox(width: 10),
              Text("SECURITY_PROTOCOL", style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("> ENTER ACCESS KEY TO PROCEED...", style: TextStyle(color: Colors.white, fontFamily: 'Courier')),
              const SizedBox(height: 15),
              if (isSubscribed)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    border: Border.all(color: kPrimaryColor),
                  ),
                  child: Column(
                    children: [
                      const Text("SUBSCRIPTION: ACTIVE", style: TextStyle(color: kPrimaryColor, fontSize: 10, fontFamily: 'Courier')),
                      Text("KEY: $kAdminKey", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Courier', fontSize: 18)),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              HackerInput(hintText: "Enter Key Here", controller: keyController, icon: Icons.vpn_key),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ABORT", style: TextStyle(color: Colors.red, fontFamily: 'Courier')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                Navigator.pop(context);
                _checkKey(keyController.text);
              },
              child: const Text("VERIFY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
            ),
          ],
        );
      },
    );
  }

  void _checkKey(String inputKey) {
    if (inputKey == kAdminKey) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: kPrimaryColor),
          title: const Text("ACCESS GRANTED", style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier')),
          content: const Text("> SMS Alert: TARGET LOCKED.\n> Request sent successfully!", style: TextStyle(color: Colors.white, fontFamily: 'Courier')),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: Colors.red),
          title: const Text("ACCESS DENIED", style: TextStyle(color: Colors.red, fontFamily: 'Courier')),
          content: const Text("> Invalid Key.\n> Purchase subscription to bypass security.", style: TextStyle(color: Colors.white, fontFamily: 'Courier')),
          actions: [
            TextButton(
              child: const Text("GET ACCESS", style: TextStyle(color: Colors.yellow, fontFamily: 'Courier')),
              onPressed: () async {
                Navigator.pop(context);
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
                if (result == true) {
                  setState(() => isSubscribed = true);
                }
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Full Device Monitoring Pro", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: kPrimaryColor, height: 1.0),
        ),
        iconTheme: const IconThemeData(color: kPrimaryColor),
        actions: [
          IconButton(icon: const Icon(Icons.wifi, color: kPrimaryColor), onPressed: () {}),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const Drawer(backgroundColor: Color(0xFF111111)),
      body: Stack(
        children: [
          // 1. Background Grid Effect (Matrix Style)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/images2.jpg"), // Optional: Add a subtle GIF if you want, or keep it black
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.darken),
                fit: BoxFit.cover,
              ),
            ),
            child: GridPaper(
              color: kPrimaryColor.withOpacity(0.1),
              interval: 50,
              divisions: 1,
              subdivisions: 1,
            ),
          ),

          // 2. Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- TERMINAL STATUS HEADER ---
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: kPrimaryColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.terminal, color: kPrimaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          statusText,
                          style: const TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- HACKER LOGO ---
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimaryColor, width: 2),
                        boxShadow: [
                          BoxShadow(color: kPrimaryColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)
                        ]
                    ),
                    child: const Icon(Icons.bug_report, size: 50, color: kPrimaryColor),
                  ),
                ),
                const SizedBox(height: 30),

                // --- SECTION 1: TARGET DEVICE ---
                _buildHackerSection(
                  title: "TARGET_CONNECTION",
                  color: kPrimaryColor,
                  child: Column(
                    children: [
                      const HackerInput(
                        hintText: "Target Phone Number",
                        prefixText: "+88 ",
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone_android,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "> Establish connection via Google Login spoofing...",
                        style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Courier'),
                      ),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "INITIATE_CONNECT()",
                        color: kRedButtonColor,
                        onPressed: _showVerificationDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- SECTION 2: FACEBOOK ATTACK ---
                _buildHackerSection(
                  title: "FB_ID_INJECTION",
                  color: kBlueButtonColor,
                  child: Column(
                    children: [
                      const Text("ফেসবুক আইডি বা পেজ লিংক দিন", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 5),
                      const HackerInput(hintText: "https://facebook.com/target_id", icon: Icons.link),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "EXECUTE_HACK()",
                        color: kBlueButtonColor,
                        onPressed: _showVerificationDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- SECTION 3: DISABLE ---
                _buildHackerSection(
                  title: "ACCOUNT_TERMINATION",
                  color: const Color(0xFFD32F2F),
                  child: Column(
                    children: [
                      const Text("Facebook Disable Request", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 5),
                      const HackerInput(hintText: "Disable Link / Evidence", icon: Icons.block),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "DESTROY_ACCOUNT()",
                        color: const Color(0xFFD32F2F),
                        onPressed: _showVerificationDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- FOOTER INFO ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white24))
                  ),
                  child: const Text(
                    "DEVICE LIMIT: 100/150 USED\n[||||||||||||||------]",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // কাস্টম হ্যাকার বক্স ডিজাইন (Container Widget)
  Widget _buildHackerSection({required String title, required Color color, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 0),
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: color.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("[$title]", style: TextStyle(color: color, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                Icon(Icons.lock_open, color: color, size: 14),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: child,
          ),
        ],
      ),
    );
  }
}