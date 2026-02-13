import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../widgets/hacker_button.dart';
import '../widgets/hacker_input.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // প্ল্যান লিস্ট
  final List<Map<String, dynamic>> plans = [
    {"name": "3 Months", "price": "2900", "duration": "90 Days"},
    {"name": "6 Months", "price": "4900", "duration": "180 Days"},
    {"name": "1 Year", "price": "6100", "duration": "365 Days"},
    {"name": "LIFETIME", "price": "12000", "duration": "∞ Forever"},
  ];

  int selectedPlanIndex = -1;
  String selectedMethod = "Bkash";
  final TextEditingController trxController = TextEditingController();
  bool isLoading = false;

  void _submitPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      _showLoginAlert();
      return;
    }

    if (selectedPlanIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a plan first!"), backgroundColor: Colors.red));
      return;
    }

    if (trxController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter valid Last 4 Digits!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.submitPayment(
      method: selectedMethod,
      amount: plans[selectedPlanIndex]['price'],
      trxInfo: trxController.text,
      plan: plans[selectedPlanIndex]['name'],
    );

    setState(() => isLoading = false);

    if (result['success']) {
      // সফল হলে পেন্ডিং মেসেজ দেখাবে
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: Colors.amber),
          title: const Row(children: [
            Icon(Icons.watch_later_outlined, color: Colors.amber),
            SizedBox(width: 10),
            Text("REQUEST SUBMITTED", style: TextStyle(color: Colors.amber, fontFamily: 'Courier', fontWeight: FontWeight.bold))
          ]),
          content: const Text(
              "আপনার পেমেন্ট রিকোয়েস্ট জমা হয়েছে।\n\nঅ্যাডমিন চেক করে অ্যাপ্রুভ করার পর আপনি টোকেন এক্সেস করতে পারবেন। অনুগ্রহ করে অপেক্ষা করুন।",
              style: TextStyle(color: Colors.white)
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ডায়লগ বন্ধ
                Navigator.pop(context); // আগের পেজে ফেরত
              },
              child: const Text("OK, I WILL WAIT", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
    }
  }

  void _showLoginAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("LOGIN REQUIRED", style: TextStyle(color: Colors.red)),
        content: const Text("Please login to purchase.", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            child: const Text("LOGIN NOW"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          )
        ],
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Scan with Bkash/Nagad", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Image.asset("assets/images/image1.jpg", height: 200, width: 200, fit: BoxFit.cover),
              const SizedBox(height: 10),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE"))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("PREMIUM PACKAGES", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kPrimaryColor),
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
                border: Border.all(color: kPrimaryColor),
                color: kPrimaryColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  _buildPaymentRow("বিকাশ (Personal)", "01781933543"),
                  const SizedBox(height: 5),
                  _buildPaymentRow("নগদ (Personal)", "01781933543"),
                  const Divider(color: Colors.grey),
                  const Text("💁 বিকাশ--নগদ- সেন্ড মানি ✅️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                    label: const Text("SHOW QR CODE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                    onPressed: _showQRCode,
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("SELECT A PLAN:", style: TextStyle(color: Colors.grey, fontFamily: 'Courier')),
            const SizedBox(height: 10),

            // --- PLAN GRID ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final isSelected = selectedPlanIndex == index;
                return InkWell(
                  onTap: () => setState(() => selectedPlanIndex = index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : const Color(0xFF111111),
                      border: Border.all(color: isSelected ? Colors.white : kPrimaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(plan['name'], style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("${plan['price']}৳", style: TextStyle(color: isSelected ? Colors.black : kPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(plan['duration'], style: TextStyle(color: isSelected ? Colors.black54 : Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text("CONFIRM PAYMENT:", style: TextStyle(color: Colors.grey, fontFamily: 'Courier')),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildMethodRadio("Bkash"),
                const SizedBox(width: 20),
                _buildMethodRadio("Nagad"),
              ],
            ),
            const SizedBox(height: 15),

            if(selectedPlanIndex != -1)
              Text("Amount to Pay: ${plans[selectedPlanIndex]['price']}৳", style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),
            HackerInput(
              hintText: "Last 4 Digits (টাকা দিয়ে লাস্ট ৪ ডিজিট বলুন)",
              controller: trxController,
              icon: Icons.numbers,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                : HackerButton(
              text: "VERIFY & UPGRADE",
              color: kPrimaryColor,
              onPressed: _submitPayment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String title, String number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: number));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Number Copied!")));
          },
          child: Row(
            children: [
              Text(number, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              const Icon(Icons.copy, size: 14, color: Colors.grey),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMethodRadio(String method) {
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = method),
      child: Row(
        children: [
          Icon(
            selectedMethod == method ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selectedMethod == method ? kPrimaryColor : Colors.grey,
          ),
          const SizedBox(width: 5),
          Text(method, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}