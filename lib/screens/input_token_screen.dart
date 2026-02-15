import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
import '../widgets/hacker_loading.dart';
import '../widgets/access_denied_dialog.dart';
import '../services/api_service.dart';
import 'subscription_screen.dart';
import 'security_alert_screen.dart';

class InputTokenScreen extends StatefulWidget {
  final String backgroundImage;

  const InputTokenScreen({
    super.key,
    required this.backgroundImage
  });

  @override
  State<InputTokenScreen> createState() => _InputTokenScreenState();
}

class _InputTokenScreenState extends State<InputTokenScreen> {
  final TextEditingController keyController = TextEditingController();
  String? serverSecretKey;
  bool isDecrypting = false;
  bool keyFound = false;
  String displayMessage = "";

  // --- ডাটাবেস থেকে কি (Key) আনার ফাংশন ---
  Future<void> _fetchKeyFromDatabase() async {
    setState(() {
      isDecrypting = true;
      displayMessage = "Connecting to Secure Server... [কানেক্ট হচ্ছে]";
    });

    final result = await ApiService.getData();
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        isDecrypting = false;

        if (result['success'] == true) {
          if (result['secret_key'] != null) {
            serverSecretKey = result['secret_key'];
            keyFound = true;
            keyController.text = serverSecretKey!;
            displayMessage = "";
          } else if (result['message'] == "Approval Pending") {
            displayMessage = "STATUS: PENDING APPROVAL [অপেক্ষমান]";
          } else {
            displayMessage = "ACCESS DENIED: SUBSCRIPTION REQUIRED [সাবস্ক্রিপশন প্রয়োজন]";
          }
        } else {
          displayMessage = "ERROR: CONNECTION FAILED [কানেকশন ব্যর্থ]";
        }
      });
    }
  }

  // --- লোডিং এনিমেশন ---
  Future<void> _showLoading(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HackerLoading(statusText: message, message: '',),
    );
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) Navigator.pop(context);
  }

  // --- ভেরিফিকেশন লজিক ---
  void _handleVerification() async {
    if (keyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Token Required! [টোকেন প্রয়োজন]"), backgroundColor: Colors.red),
      );
      return;
    }

    await _showLoading("Verifying Token Hash... [যাচাই করা হচ্ছে]");

    String inputKey = keyController.text.trim();

    if (kValidKeys.contains(inputKey)) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SecurityAlertScreen()),
        );
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const AccessDeniedDialog(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ইমেজ প্রোভাইডার চেক (Network or Asset)
    ImageProvider bgImage;
    if (widget.backgroundImage.startsWith('http')) {
      bgImage = NetworkImage(widget.backgroundImage);
    } else {
      bgImage = AssetImage(widget.backgroundImage);
    }

    return Stack(
      children: [
        // --- 1. DYNAMIC BACKGROUND WITH SHADOW OVERLAY ---
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: bgImage,
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              // 🔥 শ্যাডো ইফেক্ট (নিচ থেকে কালো হবে, উপরে একটু ক্লিয়ার)
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7), // উপরে ৭০% কালো
                  Colors.black.withOpacity(0.9), // নিচে ৯০% কালো
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // 🔥 হালকা ব্লার ইফেক্ট
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // --- 2. MAIN CONTENT ---
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("SECURE GATEWAY", style: TextStyle(fontFamily: 'Courier', color: kPrimaryColor, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: kPrimaryColor),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- ICON ---
                  const Icon(Icons.security, size: 80, color: kPrimaryColor),
                  const SizedBox(height: 20),

                  // --- TITLE ---
                  const Text(
                    "AUTHENTICATION REQUIRED\n[পরিচয় যাচাইকরণ]",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Courier', letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 30),

                  // --- 🔥 INFO CARD (NEW DESIGN) ---
                  Card(
                    color: Colors.black.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: kPrimaryColor.withOpacity(0.5))
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            "ACCESS TOKEN [অ্যাক্সেস টোকেন]",
                            style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
                          ),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text(
                            "To proceed, enter your unique ECF-KEY below.\n(সামনে এগোতে আপনার ECF-KEY দিন)\n\nYou can retrieve it automatically from our secure database.\n(অথবা ডাটাবেস থেকে অটোমেটিক সংগ্রহ করুন)",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 20),

                          // --- DATABASE FETCH BUTTON ---
                          if (isDecrypting)
                            const Column(
                              children: [
                                CircularProgressIndicator(color: kPrimaryColor),
                                SizedBox(height: 10),
                                Text("Decrypting Database... [ডিক্রিপ্ট করা হচ্ছে]", style: TextStyle(color: kPrimaryColor, fontSize: 12, fontFamily: 'Courier'))
                              ],
                            )
                          else if (keyFound)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kPrimaryColor),
                              ),
                              child: Column(
                                children: [
                                  const Text("KEY FOUND [কি পাওয়া গেছে]:", style: TextStyle(color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(serverSecretKey ?? "Unknown", style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.amber),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.cloud_download, color: Colors.amber, size: 20),
                                label: const Text("FETCH KEY [ডাটাবেস থেকে নিন]", style: TextStyle(color: Colors.amber, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                                onPressed: _fetchKeyFromDatabase,
                              ),
                            ),

                          // --- ERROR MESSAGE ---
                          if(displayMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                children: [
                                  Text(
                                    displayMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: displayMessage.contains("PENDING") ? Colors.amber : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Courier'
                                    ),
                                  ),
                                  if(displayMessage.contains("SUBSCRIPTION"))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
                                        },
                                        child: const Text("GET SUBSCRIPTION [কিনুন]", style: TextStyle(color: Colors.white)),
                                      ),
                                    )
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- INPUT FIELD ---
                  HackerInput(
                      hintText: "Enter Token (ECF-XXXX)",
                      controller: keyController,
                      icon: Icons.vpn_key_outlined
                  ),

                  const SizedBox(height: 20),

                  // --- VERIFY BUTTON ---
                  HackerButton(
                    text: "VERIFY & CONNECT [যাচাই করুন]",
                    color: kPrimaryColor,
                    onPressed: _handleVerification,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}