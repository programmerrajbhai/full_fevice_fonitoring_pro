import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../screens/subscription_screen.dart'; // সাবস্ক্রিপশন স্ক্রিনের জন্য

class AccessDeniedDialog extends StatelessWidget {
  const AccessDeniedDialog({super.key});

  // --- WHATSAPP OPENER ---
  Future<void> _openWhatsApp(String number) async {
    final Uri url = Uri.parse("https://wa.me/$number");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: Border.all(color: Colors.red, width: 2),
      title: const Row(
        children: [
          Icon(Icons.gpp_bad, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Access Denied",
              style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "আপনার দেওয়া কোডটি সঠিক নয় অথবা আপনার সাবস্ক্রিপশন সক্রিয় নেই।",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 10),
          Text(
            "এই সার্ভিস ব্যবহার করতে ভ্যালিড সাবস্ক্রিপশন প্রয়োজন।",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SUBSCRIPTION BUTTON ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.star, color: Colors.white),
              label: const Text(
                "👉 Subscription Now",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context); // ডায়লগ বন্ধ
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                );
              },
            ),

            const SizedBox(height: 15),
            const Divider(color: Colors.grey),
            const Center(child: Text("Contact Admin", style: TextStyle(color: Colors.grey, fontSize: 12))),
            const SizedBox(height: 10),

            // --- WHATSAPP BUTTONS ---
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.chat, color: Colors.green),
              label: const Text("WhatsApp: 01333819608", style: TextStyle(color: Colors.green)),
              onPressed: () => _openWhatsApp("8801333819608"),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.chat, color: Colors.green),
              label: const Text("WhatsApp: 01897737070", style: TextStyle(color: Colors.green)),
              onPressed: () => _openWhatsApp("8801897737070"),
            ),
          ],
        )
      ],
    );
  }
}