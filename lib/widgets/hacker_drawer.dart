import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../screens/login_screen.dart';
import '../screens/input_token_screen.dart';
import '../screens/support_screen.dart';
import '../screens/legal_screen.dart'; // ✅ নতুন লিগ্যাল স্ক্রিন ইম্পোর্ট করা হয়েছে

class HackerDrawer extends StatefulWidget {
  const HackerDrawer({super.key});

  @override
  State<HackerDrawer> createState() => _HackerDrawerState();
}

class _HackerDrawerState extends State<HackerDrawer> {
  String username = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "User";
    });
  }

  void _handleMenuAction(BuildContext context, String serviceKey) async {
    Navigator.pop(context); // Close Drawer

    if (serviceKey == 'support') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
      return;
    }

    // ✅ প্রাইভেসি পলিসি এবং টার্মস পেজে যাওয়ার লজিক (লগইন ছাড়াও দেখা যাবে)
    if (serviceKey == 'privacy') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(initialTabIndex: 0)));
      return;
    }
    if (serviceKey == 'terms') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(initialTabIndex: 1)));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      if (mounted) _showLoginRequiredDialog(context);
    } else {
      String imagePath = 'assets/images/images2.jpg';
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InputTokenScreen(backgroundImage: imagePath)),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) async {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("End Session?", style: TextStyle(color: kRedButtonColor, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to end your current session?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kRedButtonColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            },
            child: const Text("End Session", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: kBackgroundColor,
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  _buildSectionTitle("SUPPORT & LEGAL"),
                  _buildMenuItem(context, icon: Icons.help_outline, title: "Help & Tutorials", key: 'support'),
                  _buildMenuItem(context, icon: Icons.privacy_tip_outlined, title: "Privacy Policy", key: 'privacy'),
                  _buildMenuItem(context, icon: Icons.description_outlined, title: "Terms & Conditions", key: 'terms'),

                  _buildDivider(),

                  _buildSectionTitle("COMMUNICATION TOOLS"),
                  _buildMenuItem(context, icon: Icons.message_outlined, title: "Messenger Tools", key: 'messenger'),
                  _buildMenuItem(context, icon: Icons.chat_bubble_outline, title: "WhatsApp Tools", key: 'whatsapp'),
                  _buildMenuItem(context, icon: Icons.send_outlined, title: "Telegram Tools", key: 'telegram'),
                  _buildMenuItem(context, icon: Icons.video_call_outlined, title: "IMO Tools", key: 'imo'),

                  _buildDivider(),

                  _buildSectionTitle("SOCIAL MEDIA TOOLS"),
                  _buildMenuItem(context, icon: Icons.camera_alt_outlined, title: "Instagram Tools", key: 'instagram'),
                  _buildMenuItem(context, icon: Icons.public, title: "Facebook Tools", key: 'facebook'),
                  _buildMenuItem(context, icon: Icons.video_collection_outlined, title: "TikTok Tools", key: 'tiktok'),

                  _buildDivider(),

                  _buildSectionTitle("DEVICE MANAGEMENT"),
                  _buildMenuItem(context, icon: Icons.smartphone, title: "Device Overview", key: 'full_device'),
                  _buildMenuItem(context, icon: Icons.settings_remote, title: "Device Manager", key: 'remote'),
                  _buildMenuItem(context, icon: Icons.folder_open, title: "File Explorer", key: 'file_manager'),
                  _buildMenuItem(context, icon: Icons.image_outlined, title: "Media Viewer", key: 'gallery'),

                  _buildDivider(),

                  _buildSectionTitle("ACTIVITY & LOGS"),
                  _buildMenuItem(context, icon: Icons.search, title: "Google Activity", key: 'google'),
                  _buildMenuItem(context, icon: Icons.call_outlined, title: "Call Details", key: 'call_logs'),
                  _buildMenuItem(context, icon: Icons.camera_outlined, title: "Camera Tools", key: 'camera'),

                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: kCardColor,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kPrimaryColor, width: 2),
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: kBackgroundColor,
              backgroundImage: AssetImage("assets/images/image1.jpg"),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back",
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  username,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)
                  ),
                  child: const Text(
                    "System Status: Online",
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String key}) {
    return ListTile(
      onTap: () => _handleMenuAction(context, key),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: kPrimaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 16, color: Colors.white.withOpacity(0.3)),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kCardColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.logout, color: kRedButtonColor, size: 20),
              const SizedBox(width: 12),
              const Text("End Session", style: TextStyle(color: kRedButtonColor, fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              Text("v3.0", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Colors.white.withOpacity(0.05), thickness: 1, indent: 20, endIndent: 20),
    );
  }
}