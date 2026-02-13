import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../widgets/hacker_drawer.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
import '../widgets/hacker_loading.dart'; // নতুন ফাইল ইমপোর্ট
import '../services/api_service.dart';
import 'subscription_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool? isPremium;
  const DashboardScreen({super.key, this.isPremium});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController keyController = TextEditingController();

  String? serverSecretKey;
  String statusText = "সিস্টেম: অনলাইন... টার্গেটের জন্য অপেক্ষা করা হচ্ছে...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // হ্যাকার স্ট্যাটাস আপডেট
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          List<String> logs = [
            "পোর্ট স্ক্যান করা হচ্ছে...",
            "কানেকশন এনক্রিপ্ট করা হচ্ছে...",
            "আইপি মাস্ক করা হয়েছে: 192.168.X.X",
            "সিস্টেম নিরাপদ আছে...",
            "ইনপুটের জন্য অপেক্ষা করা হচ্ছে...",
          ];
          statusText = logs[Random().nextInt(logs.length)];
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- SHOW LOADING ANIMATION ---
  Future<void> _showLoading(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HackerLoading(message: message),
    );
    await Future.delayed(const Duration(seconds: 3)); // ৩ সেকেন্ড চলবে
    if (mounted) Navigator.pop(context); // বন্ধ হবে
  }

  // --- MAIN ACTION BUTTON LOGIC ---
  void _handleAction() async {
    // ১. প্রথমে কানেকশন লোডিং দেখাবে
    await _showLoading("টার্গেট ডিভাইসে কানেক্ট করা হচ্ছে");

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      _showLoginRequiredDialog();
    } else {
      _showVerificationDialog();
    }
  }

  // --- VERIFICATION DIALOG ---
  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDecrypting = false;
        bool keyFound = false;
        String displayMessage = "";

        return StatefulBuilder(
          builder: (context, setDialogState) {

            // সার্ভার থেকে কি (Key) আনার ফাংশন
            Future<void> fetchKeyFromDatabase() async {
              setDialogState(() {
                isDecrypting = true;
                displayMessage = "সার্ভারের সাথে কানেক্ট করা হচ্ছে...";
              });

              final result = await ApiService.getData();
              await Future.delayed(const Duration(seconds: 2));

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
                  const Text("সামনে এগোতে আপনার ECF-KEY দিন।", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),

                  if (isDecrypting) ...[
                    const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
                    const SizedBox(height: 10),
                    const Text("ডাটাবেস চেক করা হচ্ছে...", style: TextStyle(color: kPrimaryColor, fontSize: 12, fontFamily: 'Courier')),
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
                  onPressed: () async {
                    if (keyController.text.isEmpty) return;
                    Navigator.pop(context); // ডায়লগ বন্ধ

                    // ২. ভেরিফিকেশন লোডিং দেখাবে
                    await _showLoading("টোকেন যাচাই করা হচ্ছে");

                    _verifyToken(keyController.text.trim());
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

  // --- VERIFICATION CHECK ---
  void _verifyToken(String inputKey) {
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
              const Text("> পরিচয় নিশ্চিত হয়েছে।\n> কানেকশন তৈরি হয়েছে।\n> মনিটরিং শুরু করা হয়েছে।", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
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
              Text("> ভুল টোকেন দেওয়া হয়েছে।\n> শুধুমাত্র ECF-KEY গ্রহণ করা হয়।\n> অ্যাক্সেস ব্লক করা হয়েছে।", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.red),
        title: const Text("পরিচয় নিশ্চিতকরণ প্রয়োজন", style: TextStyle(color: Colors.red, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        content: const Text("সিস্টেম ব্যবহার করতে লগইন করুন।", style: TextStyle(color: Colors.white)),
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
    return Scaffold(
      drawer: const HackerDrawer(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "ফুল ডিভাইস মনিটরিং প্রো",
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: kPrimaryColor, height: 1.0),
        ),
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),

      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/images2.jpg"),
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.darken),
                fit: BoxFit.cover,
              ),
            ),
            child: GridPaper(color: kPrimaryColor.withOpacity(0.1), interval: 50, divisions: 1, subdivisions: 1),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.black, border: Border.all(color: kPrimaryColor)),
                  child: Row(children: [
                    const Icon(Icons.terminal, color: kPrimaryColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(statusText, style: const TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ]),
                ),
                const SizedBox(height: 20),

                const Center(child: Icon(Icons.bug_report, size: 80, color: kPrimaryColor)),
                const SizedBox(height: 30),

                _buildHackerSection(
                  title: "টার্গেট কানেকশন",
                  color: kPrimaryColor,
                  child: Column(
                    children: [
                      const HackerInput(hintText: "টার্গেট ফোন নম্বর দিন", prefixText: "+৮৮ ", keyboardType: TextInputType.phone, icon: Icons.phone_android),
                      const SizedBox(height: 5),
                      const Text(
                        "> গুগল লগইন স্পুফিং এর মাধ্যমে কানেকশন তৈরি করা হচ্ছে...",
                        style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Courier'),
                      ),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "কানেকশন তৈরি করুন",
                        color: kRedButtonColor,
                        onPressed: _handleAction,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildHackerSection(
                  title: "ফেসবুক আইডি হ্যাক",
                  color: kBlueButtonColor,
                  child: Column(
                    children: [
                      const HackerInput(hintText: "ফেসবুক প্রোফাইল বা পেজ লিংক দিন", icon: Icons.link),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "হ্যাক শুরু করুন",
                        color: kBlueButtonColor,
                        onPressed: _handleAction,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildHackerSection(
                  title: "অ্যাকাউন্ট ডিজেবল",
                  color: const Color(0xFFD32F2F),
                  child: Column(
                    children: [
                      const HackerInput(hintText: "ডিজেবল লিংক / প্রমাণ", icon: Icons.block),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "অ্যাকাউন্ট নষ্ট করুন",
                        color: const Color(0xFFD32F2F),
                        onPressed: _handleAction,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text("ডিভাইস লিমিট: ১০০/১৫০ ব্যবহৃত\n[||||||||||||||------]", textAlign: TextAlign.center, style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackerSection({required String title, required Color color, required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), border: Border.all(color: color.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: color.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("[$title]", style: TextStyle(color: color, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                Icon(Icons.lock_open, color: color, size: 14),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12.0), child: child),
        ],
      ),
    );
  }
}