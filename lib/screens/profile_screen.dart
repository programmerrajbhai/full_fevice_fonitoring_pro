import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_button.dart';

class ProfileScreen extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onUpgrade;

  const ProfileScreen({super.key, required this.isPremium, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    // কালার ডিসিশন (Paid হলে সবুজ, Free হলে লাল)
    final Color statusColor = isPremium ? kPrimaryColor : Colors.red;
    final String statusText = isPremium ? "ACCESS_LEVEL: ADMIN (VIP)" : "ACCESS_LEVEL: RESTRICTED (FREE)";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("USER_DOSSIER", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kPrimaryColor),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: statusColor, height: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- HACKER AVATAR SECTION ---
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Glow Circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
                        ]
                    ),
                  ),
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF111111),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  if (isPremium)
                    Positioned(
                      bottom: 0,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                        child: const Icon(Icons.star, color: Colors.black, size: 20),
                      ),
                    )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- USER DETAILS CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: statusColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow("USERNAME:", "DARK_KNIGHT_007"),
                  const Divider(color: Colors.grey),
                  _buildRow("IP ADDRESS:", "192.168.1.X [HIDDEN]"),
                  const Divider(color: Colors.grey),
                  _buildRow("STATUS:", isPremium ? "PREMIUM MEMBER" : "FREE TIER"),
                  const Divider(color: Colors.grey),
                  _buildRow("SERVER:", "ONLINE"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- STATUS DISPLAY ---
            Text(
              statusText,
              style: TextStyle(
                  color: statusColor,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),

            const SizedBox(height: 30),

            // --- ACTION BUTTON ---
            if (!isPremium) ...[
              const Text(
                "UPGRADE TO UNLOCK ALL TOOLS",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 10),
              HackerButton(
                text: "BUY PREMIUM ACCESS (\$10)",
                color: Colors.red, // লাল বাটন কারণ সাবস্ক্রিপশন নেই
                onPressed: () {
                  // সিমুলেশন: আপগ্রেড হচ্ছে
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Processing Payment... Access Granted!")),
                  );
                  onUpgrade(); // স্টেট আপডেট করবে
                },
              ),
            ] else ...[
              HackerButton(
                text: "VIEW SECRET KEYS",
                color: kPrimaryColor, // সবুজ বাটন
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("KEY: ADMIN_X_99")),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontFamily: 'Courier')),
          Text(value, style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}