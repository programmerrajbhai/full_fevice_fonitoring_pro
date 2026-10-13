import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String username = "FETCHING...";
  String phone = "ENCRYPTED";
  String joinDate = "--/--/----";
  String planType = "Basic Access";
  String planPrice = "0";
  List<dynamic> accessKeys = [];

  bool isLoading = true;
  bool isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // --- চেক লগইন স্ট্যাটাস ---
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('is_logged_in') ?? false;

    if (mounted) {
      setState(() {
        isUserLoggedIn = loggedIn;
      });

      if (loggedIn) {
        _fetchProfileData();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // --- রিয়েল টাইম ডাটা ফেচ ---
  Future<void> _fetchProfileData() async {
    setState(() => isLoading = true);

    final data = await ApiService.getProfile();

    if (mounted) {
      setState(() {
        if (data['success'] == true) {
          username = (data['username'] ?? "UNKNOWN").toString().toUpperCase();
          phone = data['phone'] ?? "HIDDEN";
          joinDate = data['joined_date'] ?? "N/A";
          planType = data['plan_type'] ?? "Basic Access";
          planPrice = data['plan_price']?.toString() ?? "0";
          accessKeys = data['access_keys'] ?? [];

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

  // --- অ্যাক্সেস কী ডায়ালগ (মডার্ন ক্লিন থিম) ---
  void _showAccessKeysDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key, color: kPrimaryColor),
            SizedBox(width: 10),
            Text("ACCESS VAULT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: kBackgroundColor,
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ACTIVE PLAN:", style: TextStyle(color: Colors.white54, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(planType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("VALUE:", style: TextStyle(color: Colors.white54, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text("$planPrice৳", style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text("DECRYPTED KEYS:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
              const Divider(color: Colors.white10),

              accessKeys.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                    child: Text(
                        "No Access Keys Found.\nUpgrade Plan to Unlock.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kRedButtonColor)
                    )
                ),
              )
                  : SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: accessKeys.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                        border: const Border(left: BorderSide(color: kPrimaryColor, width: 3)),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        title: Text(
                          accessKeys[index],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white54, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: accessKeys[index]));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Key Copied to Clipboard!"), duration: Duration(milliseconds: 1000))
                            );
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
            child: const Text("CLOSE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _navigateToSubscription() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );
    if (result == true || result == null) {
      if (isUserLoggedIn) _fetchProfileData();
    }
  }

  // --- LOGOUT HANDLER ---
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: kRedButtonColor),
            SizedBox(width: 10),
            Text("Logout Session", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          "Are you sure you want to securely log out from the server?",
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
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
            child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVip = widget.isPremium;
    final Color statusColor = isVip ? kPrimaryColor : kRedButtonColor;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: kCardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 1,
      ),

      // --- যদি লগইন করা না থাকে ---
      body: !isUserLoggedIn && !isLoading
          ? _buildLoginRequestView()
          : isLoading
          ? Center(child: CircularProgressIndicator(color: statusColor))
          : RefreshIndicator(
        onRefresh: _fetchProfileData,
        color: statusColor,
        backgroundColor: kCardColor,
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
                    color: kCardColor,
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                ),
                child: Column(
                  children: [
                    _buildRow("IDENTITY", username),
                    const Divider(color: Colors.white10),
                    _buildRow("PHONE NUMBER", phone),
                    const Divider(color: Colors.white10),
                    _buildRow("ESTABLISHED", joinDate),
                    const Divider(color: Colors.white10),
                    _buildRow("CURRENT PLAN", planType),
                    const Divider(color: Colors.white10),
                    _buildRow(
                        "ACCESS LEVEL",
                        isVip ? "PREMIUM (VIP)" : "RESTRICTED",
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
                  style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                HackerButton(
                  text: "Unlock Premium Access",
                  color: kPrimaryColor,
                  onPressed: _navigateToSubscription,
                ),
              ] else ...[
                HackerButton(
                  text: "View Access Vault",
                  color: kPrimaryColor,
                  onPressed: _showAccessKeysDialog,
                ),
              ],

              const SizedBox(height: 15),

              // --- LOGOUT BUTTON ---
              HackerButton(
                text: "Logout System",
                color: kRedButtonColor,
                onPressed: _handleLogout,
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: const Text(
                  "SESSION ID: 8X99-AF22 [SECURE]",
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- লগইন রিকোয়েস্ট ভিউ ---
  Widget _buildLoginRequestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            const Text(
              "Authentication Required",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "You must be logged in to view your profile and manage access settings.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text("Go to Login", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
              ),
            )
          ],
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.8), width: 3),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 54,
            backgroundColor: kBackgroundColor,
            backgroundImage: AssetImage("assets/images/image1.jpg"),
          ),
          if (isVip)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kCardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(Icons.verified_user, color: color, size: 18),
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
            style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? Colors.white,
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