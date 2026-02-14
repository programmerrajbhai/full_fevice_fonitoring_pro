import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../widgets/hacker_button.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

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
        title: const Text("SECURITY VERIFICATION", style: TextStyle(fontFamily: 'Courier', color: kPrimaryColor)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.orange),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                color: Colors.orange.withOpacity(0.1),
              ),
              child: const Column(
                children: [
                  Text("সতর্কতা: নতুন ডিভাইস শনাক্ত হয়েছে", style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    "নিরাপত্তার জন্য সাময়িক refundable verification প্রয়োজন।\n✔️ Verification সম্পন্ন হলে জমা ফেরতযোগ্য।",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            HackerButton(
              text: "👉 Verify Now (Payment Link)",
              color: kPrimaryColor,
              onPressed: () {
                // ✅ লিংক এখানেও আপডেট করা হয়েছে
                _launchURL("https://teamethicalcyberforce.com/product/server-security-payment/");
              },
            ),

            const SizedBox(height: 15),

            HackerButton(
              text: "👉 Contact Admin",
              color: Colors.red,
              onPressed: () {
                _launchURL("https://wa.me/8801333819608");
              },
            ),
          ],
        ),
      ),
    );
  }
}