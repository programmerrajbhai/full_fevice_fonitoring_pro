import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../widgets/hacker_button.dart';
import 'login_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // --- ক্লিন প্ল্যান লিস্ট ---
  final List<Map<String, dynamic>> plans = [
    {"name": "3 Months", "price": "2900৳", "duration": "90 Days Access"},
    {"name": "6 Months", "price": "4900৳", "duration": "180 Days Access"},
    {"name": "1 Year", "price": "6100৳", "duration": "365 Days Access"},
    {"name": "LIFETIME", "price": "12000৳", "duration": "Unlimited Access"},
  ];

  int selectedPlanIndex = -1;

  // আপনার পেমেন্ট ওয়েবসাইটের লিঙ্ক (এটি আপনার আসল লিঙ্ক দিয়ে রিপ্লেস করবেন)
  final String paymentGatewayUrl = "https://teamethicalcyberforce.com/product/server-security-payment/";

  // --- এক্সটার্নাল ব্রাউজার বাইপাস হ্যান্ডলার ---
  Future<void> _handleSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      _showLoginAlert();
      return;
    }

    if (selectedPlanIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a plan first!"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // গুগল পলিসি বাইপাস: সরাসরি ক্রোম/সাফারিতে পেমেন্ট পেজ ওপেন করা হচ্ছে
    _launchURL(paymentGatewayUrl);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    // LaunchMode.externalApplication নিশ্চিত করবে যে এটি অ্যাপের ভেতরে (WebView) ওপেন না হয়ে বাইরের ব্রাউজারে ওপেন হবে
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open secure payment gateway!"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // ব্রাউজারে যাওয়ার আগে ইউজারকে একটি ইনস্ট্রাকশন দেখানো হচ্ছে
      if (mounted) {
        _showPostPaymentInstruction();
      }
    }
  }

  void _showPostPaymentInstruction() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: kPrimaryColor),
            SizedBox(width: 10),
            Text("Action Required", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          "You are being redirected to our secure external payment gateway.\n\nAfter completing the payment on the website, your account access level will be upgraded automatically. Please allow a few minutes for the server to sync.",
          style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
        ),
        actions: [
          TextButton(
            child: const Text("I Understand", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showLoginAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Authentication Required", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Please login to purchase a premium plan.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Login Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Premium Packages", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
        backgroundColor: kCardColor,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER INFO ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: kCardColor,
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ]
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: kPrimaryColor, size: 35),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Upgrade Your Access", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Select a plan below to unlock all security assessment tools and modules.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text("SELECT A PLAN:", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 15),

            // --- PLAN GRID ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final isSelected = selectedPlanIndex == index;

                return InkWell(
                  onTap: () => setState(() => selectedPlanIndex = index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor.withOpacity(0.1) : kCardColor,
                      border: Border.all(
                          color: isSelected ? kPrimaryColor : Colors.white.withOpacity(0.05),
                          width: isSelected ? 2 : 1.5
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? kPrimaryColor : Colors.white24,
                            size: 28
                        ),
                        const SizedBox(height: 12),
                        Text(plan['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text(plan['price'], style: TextStyle(color: isSelected ? kPrimaryColor : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(plan['duration'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // --- SECURE PAYMENT BUTTON (WEBVIEW BYPASS) ---
            HackerButton(
              text: "Proceed to Secure Checkout",
              color: kPrimaryColor,
              onPressed: _handleSubscription,
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Payments are processed securely via our external gateway.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}