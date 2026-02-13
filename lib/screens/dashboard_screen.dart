import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../widgets/hacker_drawer.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
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
  String statusText = "SYSTEM: ONLINE... WAITING FOR TARGET...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          List<String> logs = [
            "SCANNING PORTS...",
            "ENCRYPTING CONNECTION...",
            "IP MASKED: 192.168.X.X",
            "SYSTEM SECURE...",
            "WAITING FOR INPUT...",
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

  void _handleAction() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // নোট: আমরা এখানে 'isPremium' চেক করছি না, কারণ ইউজার 'Verify' বাটনে ক্লিক করে
    // ডাটাবেস থেকে টোকেন চেক করবে যে তার এপ্রুভাল হয়েছে কিনা।
    if (!isLoggedIn) {
      _showLoginRequiredDialog();
    } else {
      _showVerificationDialog();
    }
  }

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
            // --- SERVER TOKEN FETCH LOGIC ---
            Future<void> fetchKeyFromDatabase() async {
              setDialogState(() {
                isDecrypting = true;
                displayMessage = "";
              });

              // সার্ভারে কল করা হচ্ছে (get_data.php)
              final result = await ApiService.getData();

              await Future.delayed(
                const Duration(seconds: 3),
              ); // Hacker Animation Delay

              if (mounted) {
                setDialogState(() {
                  isDecrypting = false;

                  if (result['success'] == true) {
                    if (result['secret_key'] != null) {
                      // ১. টোকেন পাওয়া গেছে (Approved)
                      serverSecretKey = result['secret_key'];
                      keyFound = true;
                      keyController.text = serverSecretKey!;
                    } else if (result['message'] == "Approval Pending") {
                      // ২. রিকোয়েস্ট পেন্ডিং
                      displayMessage =
                          "STATUS: PENDING APPROVAL (Wait for Admin)";
                    } else {
                      // ৩. সাবস্ক্রিপশন নেই
                      displayMessage = "ACCESS DENIED: Subscription Required";
                    }
                  } else {
                    displayMessage = "CONNECTION ERROR: Server Unreachable";
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
                  Text(
                    "SECURE ACCESS",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "> AUTHENTICATION REQUIRED",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Retrieve Access Token from Secure Database.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  if (isDecrypting) ...[
                    const Text(
                      "CONNECTING TO ENCRYPTED SERVER...",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 10,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 5),
                    const LinearProgressIndicator(
                      backgroundColor: Colors.white10,
                      color: kPrimaryColor,
                    ),
                  ] else if (keyFound) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        border: Border.all(color: kPrimaryColor),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "TOKEN DECRYPTED SUCCESSFULLY",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            serverSecretKey ?? "Unknown",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // টোকেন ফেচ বাটন
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.cloud_download,
                          color: Colors.amber,
                        ),
                        label: const Text(
                          "GET TOKEN (DATABASE)",
                          style: TextStyle(
                            color: Colors.amber,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: fetchKeyFromDatabase,
                      ),
                    ),
                    if (displayMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            displayMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: displayMessage.contains("PENDING")
                                  ? Colors.amber
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                      ),

                    // যদি অ্যাক্সেস ডিনাইড হয়, সাবস্ক্রিপশন বাটন দেখাও
                    if (displayMessage.contains("Required"))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: HackerButton(
                          text: "BUY SUBSCRIPTION",
                          color: Colors.red,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SubscriptionScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                  ],

                  const SizedBox(height: 20),
                  HackerInput(
                    hintText: "Enter Token",
                    controller: keyController,
                    icon: Icons.password,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    keyController.clear();
                  },
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: () {
                    if (keyController.text.isEmpty) return;
                    Navigator.pop(context);
                    _verifyToken(keyController.text);
                  },
                  child: const Text(
                    "VERIFY",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _verifyToken(String inputKey) {
    // সার্ভার থেকে কি না আসলে ডিফল্ট কি (fallback)
    String validKey = serverSecretKey ?? kAdminKey;

    if (inputKey == validKey) {
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
              const Text(
                "ACCESS GRANTED",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 20,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "> Connection Established.\n> Target Device Monitoring Started.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
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
              Text(
                "ACCESS DENIED",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "> Invalid Token.\n> System Lockdown Initiated.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
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
        title: const Text(
          "IDENTITY REQUIRED",
          style: TextStyle(color: Colors.red, fontFamily: 'Courier'),
        ),
        content: const Text(
          "System requires valid login session.",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
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
          "Full Device Monitoring Pro",
          style: TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.9),
                  BlendMode.darken,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: GridPaper(
              color: kPrimaryColor.withOpacity(0.1),
              interval: 50,
              divisions: 1,
              subdivisions: 1,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: kPrimaryColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.terminal,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontFamily: 'Courier',
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Icon(Icons.bug_report, size: 80, color: kPrimaryColor),
                ),
                const SizedBox(height: 30),
                _buildHackerSection(
                  title: "TARGET_CONNECTION",
                  color: kPrimaryColor,
                  child: Column(
                    children: [
                      const HackerInput(
                        hintText: "Target Phone Number",
                        prefixText: "+88 ",
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone_android,
                      ),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "INITIATE_CONNECT()",
                        color: kRedButtonColor,
                        onPressed: _handleAction,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildHackerSection(
                  title: "FB_ID_INJECTION",
                  color: kBlueButtonColor,
                  child: Column(
                    children: [
                      const HackerInput(
                        hintText: "https://facebook.com/target_id",
                        icon: Icons.link,
                      ),
                      const SizedBox(height: 10),
                      HackerButton(
                        text: "EXECUTE_HACK()",
                        color: kBlueButtonColor,
                        onPressed: _handleAction,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "DEVICE LIMIT: 100/150 USED\n[||||||||||||||------]",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackerSection({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: color.withOpacity(0.2),
            child: Text(
              "[$title]",
              style: TextStyle(
                color: color,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(12.0), child: child),
        ],
      ),
    );
  }
}
