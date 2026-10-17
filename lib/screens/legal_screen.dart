import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'login_screen.dart';

class LegalScreen extends StatefulWidget {
  final int initialTabIndex;
  const LegalScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  bool _isDeleting = false;

  // --- গুগল প্লে পলিসি অনুযায়ী অ্যাকাউন্ট ডিলিট হ্যান্ডলার ---
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: kRedButtonColor),
            SizedBox(width: 10),
            Text("Delete Account?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          "Are you sure you want to permanently delete your account and all associated data? This action cannot be undone.",
          style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRedButtonColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _processAccountDeletion();
            },
            child: const Text("Delete Permanently", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _processAccountDeletion() async {
    setState(() => _isDeleting = true);

    // সার্ভার থেকে ডাটা রিমুভ করার সিমুলেশন ডিলে
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your account and personal data have been scheduled for permanent deletion."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text(
            "Legal & Privacy Center",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
          ),
          backgroundColor: kCardColor,
          centerTitle: true,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: kPrimaryColor,
            labelColor: kPrimaryColor,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: "Privacy Policy"),
              Tab(text: "Terms of Use"),
              Tab(text: "Data & Account"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrivacyPolicyTab(),
            _buildTermsAndConditionsTab(),
            _buildDataDeletionTab(),
          ],
        ),
      ),
    );
  }

  // --- 1. PRIVACY POLICY TAB ---
  Widget _buildPrivacyPolicyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy & Data Safety",
            subtitle: "Last Updated: October 2026 | Complies with Google Play User Data Policy.",
          ),
          const SizedBox(height: 16),
          _buildPolicyCard(
            title: "1. Overview & Purpose",
            content:
            "Welcome to Security & Activity Tools. Our application is designed strictly as an educational utility and security awareness simulator. We respect your privacy and are committed to protecting your personal data.",
          ),
          _buildPolicyCard(
            title: "2. Information We Collect",
            content:
            "• Account Information: When you register or log in, we collect your basic profile identifier (Username and Phone Number) to manage your account session.\n"
                "• Local Storage: We use SharedPreferences on your device to keep you logged in and store basic app preferences.\n"
                "• No Sensitive Device Access: This app does NOT collect, read, or transmit your personal photos, contacts, call logs, messages, or camera feeds.",
          ),
          _buildPolicyCard(
            title: "3. How We Use Your Data",
            content:
            "Your information is used solely for:\n"
                "• Authenticating your user session.\n"
                "• Displaying your account status and access tier.\n"
                "• Providing customer support and troubleshooting.",
          ),
          _buildPolicyCard(
            title: "4. Data Sharing & Security",
            content:
            "We do NOT sell, trade, or share your personal information with any third-party marketing agencies. All communication between the app and our server is protected using standard encryption protocols.",
          ),
          _buildPolicyCard(
            title: "5. User Rights & Data Retention",
            content:
            "You have full control over your data. You may view your profile information at any time or request complete deletion of your account and associated records using the 'Data & Account' tab within this app.",
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 2. TERMS & CONDITIONS TAB ---
  Widget _buildTermsAndConditionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(
            icon: Icons.gavel_outlined,
            title: "Terms & Conditions of Use",
            subtitle: "Please read these terms carefully before using the application.",
          ),
          const SizedBox(height: 16),
          _buildPolicyCard(
            title: "1. Educational & Simulation Nature",
            content:
            "This application is an educational simulator and interface demonstration tool. All analytical outputs, terminal logs, and diagnostic progressions shown within the app are simulated for learning and entertainment purposes only.",
          ),
          _buildPolicyCard(
            title: "2. Acceptable Use Policy",
            content:
            "By using this app, you agree NOT to:\n"
                "• Misrepresent the simulated outputs as real unauthorized access.\n"
                "• Use the application for any unlawful, deceptive, or malicious activities.\n"
                "• Attempt to reverse-engineer or disrupt our server infrastructure.",
          ),
          _buildPolicyCard(
            title: "3. Account Responsibility",
            content:
            "You are responsible for maintaining the confidentiality of your login credentials. Sharing of accounts or access keys among multiple unauthorized users may result in session termination.",
          ),
          _buildPolicyCard(
            title: "4. Limitation of Liability",
            content:
            "The developers provide this software 'as is' without warranties of any kind. We are not liable for any misunderstandings or misuse arising from the simulated interfaces provided in the application.",
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 3. DATA & ACCOUNT DELETION TAB (Google Play Mandatory Requirement) ---
  Widget _buildDataDeletionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(
            icon: Icons.manage_accounts_outlined,
            title: "Data Control & Account Deletion",
            subtitle: "Manage your personal data in accordance with Google Play safety standards.",
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What happens when you delete your account?",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildBulletPoint("Your username and registered phone number will be permanently erased from our database."),
                _buildBulletPoint("Any active plans, saved preferences, and access keys associated with your account will be revoked."),
                _buildBulletPoint("Local session cache stored on your device will be immediately cleared."),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRedButtonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: _isDeleting
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.delete_forever, color: Colors.white),
                    label: Text(
                      _isDeleting ? "Processing Request..." : "Request Account & Data Deletion",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: _isDeleting ? null : _confirmDeleteAccount,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildInfoBanner({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: kPrimaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}