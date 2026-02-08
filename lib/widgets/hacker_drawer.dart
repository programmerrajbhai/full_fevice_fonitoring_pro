import 'package:flutter/material.dart';
import '../constants.dart'; // আপনার constants ফাইল ইম্পোর্ট করুন

class HackerDrawer extends StatelessWidget {
  const HackerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // পুরো ড্রয়ারের শেপ এবং ব্যাকগ্রাউন্ড
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(20)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: const Border(right: BorderSide(color: kPrimaryColor, width: 2)), // ডান পাশে নিয়ন বর্ডার
          boxShadow: [
            BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
          ],
        ),
        child: Column(
          children: [
            // --- HEADER SECTION ---
            _buildHeader(),

            // --- MENU ITEMS LIST ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDivider(),
                  _buildMenuItem(icon: Icons.dashboard, title: "DASHBOARD", onTap: () {}),
                  _buildMenuItem(icon: Icons.message, title: "MESSENGER", onTap: () {}),
                  _buildMenuItem(icon: Icons.chat, title: "WHATSAPP", onTap: () {}),
                  _buildMenuItem(icon: Icons.send, title: "TELEGRAM", onTap: () {}),
                  _buildMenuItem(icon: Icons.camera_alt, title: "INSTAGRAM", onTap: () {}),
                  _buildMenuItem(icon: Icons.facebook, title: "FACEBOOK", onTap: () {}),

                  _buildDivider(),

                  _buildMenuItem(icon: Icons.folder_open, title: "FILE_MANAGER", onTap: () {}),
                  _buildMenuItem(icon: Icons.image, title: "GALLERY", onTap: () {}),
                  _buildMenuItem(icon: Icons.video_call, title: "IMO_HACK", onTap: () {}),
                  _buildMenuItem(icon: Icons.tiktok, title: "TIKTOK_ACCESS", onTap: () {}),
                  _buildMenuItem(icon: Icons.settings_remote, title: "REMOTE_CONTROL", onTap: () {}),
                  _buildMenuItem(icon: Icons.phone_android, title: "FULL_DEVICE", onTap: () {}),

                  _buildDivider(),

                  _buildMenuItem(icon: Icons.g_mobiledata, title: "GOOGLE_LOGS", onTap: () {}),
                  _buildMenuItem(icon: Icons.call, title: "CALL_HISTORY", onTap: () {}),
                  _buildMenuItem(icon: Icons.support_agent, title: "SUPPORT", onTap: () {}),
                  _buildMenuItem(icon: Icons.camera, title: "SPY_CAMERA", onTap: () {}, isWarning: true),
                ],
              ),
            ),

            // --- FOOTER SECTION ---
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ১. হেডার ডিজাইন (প্রোফাইল)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(bottom: BorderSide(color: kPrimaryColor.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          // প্রোফাইল ইমেজ এর চারপাশে গ্লোয়িং বর্ডার
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPrimaryColor, width: 2),
                boxShadow: [
                  BoxShadow(color: kPrimaryColor.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)
                ]
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage("assets/images/image1.jpg"), // এখানে আপনার ইমেজ দিন
              child: Icon(Icons.person, size: 40, color: Colors.grey), // ইমেজ না থাকলে আইকন দেখাবে
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "",
            style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "STATUS: ONLINE [Encrypted]",
            style: TextStyle(color: Colors.grey, fontFamily: 'Courier', fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ২. মেনু আইটেম ডিজাইন
  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap, bool isWarning = false}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(
          icon,
          color: isWarning ? Colors.red : kPrimaryColor,
          size: 22
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isWarning ? Colors.redAccent : Colors.white,
          fontFamily: 'Courier',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      // ডান পাশে ছোট অ্যারো
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[800]),
      hoverColor: kPrimaryColor.withOpacity(0.1),
    );
  }

  // ৩. ফুটার ডিজাইন (লগ আউট)
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: InkWell(
        onTap: () {
          // লগ আউট লজিক
        },
        child: Row(
          children: [
            const Icon(Icons.power_settings_new, color: Colors.red),
            const SizedBox(width: 10),
            const Text(
              "DISCONNECT_SYSTEM",
              style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text("v2.0", style: TextStyle(color: Colors.grey[700], fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ৪. ডিভাইডার
  Widget _buildDivider() {
    return Divider(color: kPrimaryColor.withOpacity(0.2), thickness: 1, indent: 20, endIndent: 20);
  }
}