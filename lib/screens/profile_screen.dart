import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ক্লিপবোর্ড এর জন্য
import '../constants.dart';
import '../widgets/hacker_button.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'subscription_screen.dart';

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
  // ডাটা হোল্ডার ভেরিয়েবল
  String username = "FETCHING...";
  String email = "ENCRYPTED";
  String joinDate = "--/--/----";
  String planType = "Free Tier";
  String planPrice = "0"; // নতুন: প্ল্যানের দাম
  List<dynamic> accessKeys = []; // নতুন: কী (Keys) এর লিস্ট
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // --- 1. REAL-TIME DATA FETCH ---
  Future<void> _fetchProfileData() async {
    setState(() => isLoading = true);

    final data = await ApiService.getProfile();

    if (mounted) {
      setState(() {
        if (data['success'] == true) {
          username = (data['username'] ?? "UNKNOWN").toString().toUpperCase();
          email = data['email'] ?? "HIDDEN";
          joinDate = data['joined_date'] ?? "N/A";
          planType = data['plan_type'] ?? "Free Tier";
          planPrice = data['plan_price']?.toString() ?? "0"; // প্রাইস সেট করা হলো
          accessKeys = data['access_keys'] ?? []; // কী লিস্ট সেট করা হলো

          // যদি সার্ভার বলে সাবস্ক্রাইবড, কিন্তু অ্যাপে আপডেট না থাকে
          if (data['is_subscribed'] == true && !widget.isPremium) {
            widget.onUpgrade();
          }
        } else {
          username = "ERROR LOADING";
        }
        isLoading = false;
      });
    }
  }

  // --- 2. ACCESS KEYS DIALOG (NEW UI) ---
  void _showAccessKeysDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: kBlueButtonColor, width: 2),
        title: const Row(
          children: [
            Icon(Icons.vpn_key, color: kBlueButtonColor),
            SizedBox(width: 10),
            Text("ACCESS VAULT", style: TextStyle(color: kBlueButtonColor, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Plan Details Box ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: kBlueButtonColor.withOpacity(0.1),
                    border: Border.all(color: kBlueButtonColor.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ACTIVE PLAN:", style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Courier')),
                        const SizedBox(height: 2),
                        Text(planType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("VALUE:", style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Courier')),
                        const SizedBox(height: 2),
                        Text("$planPrice৳", style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Courier')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text("> DECRYPTED KEYS:", style: TextStyle(color: Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
              const Divider(color: Colors.grey),

              // --- Keys List ---
              accessKeys.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(child: Text("No Access Keys Found.\nUpgrade Plan to Unlock.", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontFamily: 'Courier'))),
              )
                  : SizedBox(
                height: 200, // লিস্টের জন্য হাইট ফিক্স করা
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: accessKeys.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        border: Border(left: BorderSide(color: kPrimaryColor, width: 3)),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        title: Text(
                          accessKeys[index],
                          style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, color: Colors.amber, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: accessKeys[index]));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Key Copied to Clipboard!"), duration: Duration(milliseconds: 500)));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE VAULT", style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- NAVIGATION ---
  void _navigateToSubscription() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );
    // পেজ থেকে ফিরলে ডাটা রিফ্রেশ হবে
    if (result == true || result == null) {
      _fetchProfileData();
    }
  }

  // --- LOGOUT ---
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.red, width: 2),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text("TERMINATE SESSION", style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
          ],
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            },
            child: const Text("DISCONNECT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kPrimaryColor),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: statusColor, height: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProfileData,
            tooltip: "Refresh Data",
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: statusColor))
          : RefreshIndicator(
        onRefresh: _fetchProfileData,
        color: statusColor,
        backgroundColor: Colors.grey[900],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- AVATAR SECTION ---
              _buildAvatarSection(statusColor, isVip),

              const SizedBox(height: 30),

              // --- INFO CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    border: Border.all(color: statusColor.withOpacity(0.6), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
                    ]
                ),
                child: Column(
                  children: [
                    _buildRow("IDENTITY", username),
                    const Divider(color: Colors.white10),
                    _buildRow("EMAIL", email),
                    const Divider(color: Colors.white10),
                    _buildRow("ESTABLISHED", joinDate),
                    const Divider(color: Colors.white10),
                    _buildRow("CURRENT PLAN", planType), // রিয়েল প্ল্যান
                    const Divider(color: Colors.white10),
                    _buildRow(
                        "ACCESS LEVEL",
                        isVip ? "ADMIN (VIP)" : "RESTRICTED",
                        valueColor: statusColor
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- ACTION BUTTONS ---
              if (!isVip) ...[
                const Text(
                  "UPGRADE REQUIRED FOR FULL ACCESS",
                  style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Courier', letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                HackerButton(
                  text: "UNLOCK PREMIUM (PACKAGES)",
                  color: kPrimaryColor,
                  onPressed: _navigateToSubscription,
                ),
              ] else ...[
                // প্রিমিয়াম ইউজারদের জন্য ভিউ অ্যাক্সেস বাটন
                HackerButton(
                  text: "VIEW ACCESS KEYS & PLAN",
                  color: kBlueButtonColor,
                  onPressed: _showAccessKeysDialog, // ডায়লগ কল করা হচ্ছে
                ),
              ],

              const SizedBox(height: 15),

              // --- LOGOUT BUTTON ---
              HackerButton(
                text: "DISCONNECT SYSTEM",
                color: const Color(0xFFB71C1C),
                onPressed: _handleLogout,
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: const Text(
                  "SESSION ID: 8X99-AF22 [SECURE]",
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Courier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildAvatarSection(Color color, bool isVip) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.6), width: 2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
              ],
            ),
          ),
          CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFF1A1A1A),
            child: Icon(Icons.person, size: 60, color: Colors.white.withOpacity(0.8)),
          ),
          if (isVip)
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(Icons.verified_user, color: color, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? Colors.white,
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