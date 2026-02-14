import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../screens/login_screen.dart';
import '../screens/subscription_screen.dart';
import 'hacker_input.dart';
import 'hacker_button.dart';

class HackerDrawer extends StatefulWidget {
  const HackerDrawer({super.key});

  @override
  State<HackerDrawer> createState() => _HackerDrawerState();
}

class _HackerDrawerState extends State<HackerDrawer> {
  final TextEditingController keyController = TextEditingController();
  String? serverSecretKey;

  // --- 1. ACTION HANDLER ---
  void _handleMenuAction(BuildContext context) async {
    Navigator.pop(context); // ড্রয়ার বন্ধ হবে

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      _showLoginRequiredDialog(context);
    } else {
      _showVerificationDialog(context);
    }
  }

  // --- 2. LOGOUT HANDLER ---
  void _handleLogout(BuildContext context) async {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.red),
        title: const Text("সেশন বন্ধ করুন?", style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        content: const Text("আপনি কি সার্ভার থেকে ডিসকানেক্ট হতে চান?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text("হ্যাঁ, করুন", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 3. VERIFICATION DIALOG ---
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDecrypting = false;
        bool keyFound = false;
        String displayMessage = "";

        return StatefulBuilder(
          builder: (context, setDialogState) {

            // ডাটাবেস থেকে কি (Key) আনার ফাংশন
            Future<void> fetchKeyFromDatabase() async {
              setDialogState(() {
                isDecrypting = true;
                displayMessage = "সার্ভারের সাথে কানেক্ট করা হচ্ছে...";
              });

              final result = await ApiService.getData();

              // হ্যাকার এনিমেশনের জন্য ৩ সেকেন্ড ডিলে
              await Future.delayed(const Duration(seconds: 3));

              if (mounted) {
                setDialogState(() {
                  isDecrypting = false;

                  if (result['success'] == true) {
                    if (result['secret_key'] != null) {
                      serverSecretKey = result['secret_key'];
                      keyFound = true;
                      keyController.text = serverSecretKey!;
                      displayMessage = "";
                    } else if (result['message'] == "Approval Pending") {
                      displayMessage = "স্ট্যাটাস: অ্যাডমিন অনুমোদনের অপেক্ষায় (পেন্ডিং)";
                    } else {
                      displayMessage = "অ্যাক্সেস নেই: সাবস্ক্রিপশন প্রয়োজন";
                    }
                  } else {
                    displayMessage = "ত্রুটি: সার্ভার কানেকশন ব্যর্থ হয়েছে";
                  }
                });
              }
            }

            return AlertDialog(
              backgroundColor: Colors.black,
              shape: Border.all(color: kPrimaryColor, width: 2),
              title: const Row(
                children: [
                  Icon(Icons.vpn_key, color: kPrimaryColor),
                  SizedBox(width: 10),
                  Text("নিরাপত্তা প্রোটোকল", style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("> অনুমোদনের প্রয়োজন", style: TextStyle(color: Colors.white, fontFamily: 'Courier')),
                  const SizedBox(height: 5),
                  const Text("টুলস এক্সেস করতে আপনার ECF-KEY দিন।", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),

                  if (isDecrypting) ...[
                    const Text("ডিক্রিপ্ট করা হচ্ছে...", style: TextStyle(color: kPrimaryColor, fontSize: 10, fontFamily: 'Courier')),
                    const SizedBox(height: 5),
                    const LinearProgressIndicator(backgroundColor: Colors.white10, color: kPrimaryColor),
                  ] else if (keyFound) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), border: Border.all(color: kPrimaryColor)),
                      child: Column(
                        children: [
                          const Text("অ্যাক্সেস অনুমোদিত", style: TextStyle(color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(serverSecretKey ?? "Unknown", style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cloud_download, color: Colors.amber),
                        label: const Text("টোকেন নিন (ডাটাবেস)", style: TextStyle(color: Colors.amber, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.amber), padding: const EdgeInsets.symmetric(vertical: 15)),
                        onPressed: fetchKeyFromDatabase,
                      ),
                    ),
                    if(displayMessage.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Center(
                              child: Text(
                                  displayMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: displayMessage.contains("পেন্ডিং") ? Colors.amber : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                  )
                              )
                          )
                      ),

                    if(displayMessage.contains("সাবস্ক্রিপশন"))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: HackerButton(
                          text: "সাবস্ক্রিপশন কিনুন",
                          color: Colors.red[900]!,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
                          },
                        ),
                      )
                  ],

                  const SizedBox(height: 20),
                  HackerInput(hintText: "টোকেন দিন (ECF-...)", controller: keyController, icon: Icons.password),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    keyController.clear();
                  },
                  child: const Text("বন্ধ করুন", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  onPressed: () {
                    if (keyController.text.isEmpty) return;
                    Navigator.pop(context);
                    _verifyToken(context, keyController.text.trim());
                  },
                  child: const Text("যাচাই করুন", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- 4. VERIFY TOKEN LOGIC ---
  void _verifyToken(BuildContext context, String inputKey) {
    if (kValidKeys.contains(inputKey)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: kPrimaryColor),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: kPrimaryColor, size: 60),
              const SizedBox(height: 10),
              const Text("অ্যাক্সেস অনুমোদিত", style: TextStyle(color: kPrimaryColor, fontSize: 20, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("> টুলস ওপেন করা হচ্ছে...\n> কানেকশন তৈরি হয়েছে।", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: Colors.red),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 60),
              SizedBox(height: 10),
              Text("অ্যাক্সেস বাতিল", style: TextStyle(color: Colors.red, fontSize: 20, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("> ভুল টোকেন।\n> অ্যাক্সেস ব্লক করা হয়েছে।", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.red),
        title: const Text("পরিচয় নিশ্চিতকরণ প্রয়োজন", style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        content: const Text("এই টুলস ব্যবহার করতে লগইন করুন।", style: TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("লগইন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(20)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: const Border(right: BorderSide(color: kPrimaryColor, width: 2)),
          boxShadow: [
            BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDivider(),
                  _buildMenuItem(context, icon: Icons.dashboard, title: "ড্যাশবোর্ড (DASHBOARD)", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.message, title: "মেসেঞ্জার (MESSENGER)", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.chat, title: "হোয়াটসঅ্যাপ (WHATSAPP)", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.send, title: "টেলিগ্রাম (TELEGRAM)", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.camera_alt, title: "ইন্সটাগ্রাম (INSTAGRAM)", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.facebook, title: "ফেসবুক (FACEBOOK)", onTap: () {}),

                  _buildDivider(),

                  _buildMenuItem(context, icon: Icons.folder_open, title: "ফাইল ম্যানেজার", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.image, title: "গ্যালারি হ্যাক", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.video_call, title: "ইমু হ্যাক (IMO)", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.tiktok, title: "টিকটক এক্সেস", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.settings_remote, title: "রিমোট কন্ট্রোল", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.phone_android, title: "ফুল ডিভাইস", onTap: () {}),

                  _buildDivider(),

                  _buildMenuItem(context, icon: Icons.g_mobiledata, title: "গুগল লগস", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.call, title: "কল হিস্টোরি", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.support_agent, title: "সাপোর্ট", onTap: () {}),
                  _buildMenuItem(context, icon: Icons.camera, title: "স্পাই ক্যামেরা", onTap: () {}, isWarning: true),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(bottom: BorderSide(color: kPrimaryColor.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPrimaryColor, width: 2),
                boxShadow: [
                  BoxShadow(color: kPrimaryColor.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)
                ]
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage("assets/images/image1.jpg"),
              child: Icon(Icons.person, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "অ্যাডমিন ইউজার",
            style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "স্ট্যাটাস: অনলাইন [এনক্রিপ্টেড]",
            style: TextStyle(color: Colors.grey, fontFamily: 'Courier', fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, bool isWarning = false}) {
    return ListTile(
      onTap: () => _handleMenuAction(context), // সব মেনু আইটেমে ভেরিফিকেশন কল করা হলো
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(
          icon,
          color: isWarning ? Colors.red : kPrimaryColor,
          size: 22
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isWarning ? Colors.redAccent : Colors.white,
          fontFamily: 'Courier',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[800]),
      hoverColor: kPrimaryColor.withOpacity(0.1),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: InkWell(
        onTap: () => _handleLogout(context), // লগআউট একশন
        child: Row(
          children: [
            const Icon(Icons.power_settings_new, color: Colors.red),
            const SizedBox(width: 10),
            const Text(
              "সিস্টেম বন্ধ করুন",
              style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text("v2.0", style: TextStyle(color: Colors.grey[700], fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: kPrimaryColor.withOpacity(0.2), thickness: 1, indent: 20, endIndent: 20);
  }
}