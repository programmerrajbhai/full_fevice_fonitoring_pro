import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_button.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("VIP ACCESS", style: TextStyle(color: kPrimaryColor)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.diamond, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                "Buy Subscription Required",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "To get the SECRET KEY, you need to purchase a plan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              HackerButton(
                text: "BUY NOW - 10",
                color: kPrimaryColor,
                onPressed: () {
                  // সাবস্ক্রিপশন কেনা হলে ড্যাশবোর্ডে সত্য (true) রিটার্ন করবে
                  Navigator.pop(context, true);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}