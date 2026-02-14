import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
import '../services/api_service.dart';
import 'main_layout.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool isLoading = false;

  void _handleLogin() async {
    // ইমেইল বা পাসওয়ার্ড খালি থাকলে চেক
    if (emailController.text.trim().isEmpty || passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => isLoading = true);

    // কিবোর্ড নামিয়ে দেওয়ার জন্য
    FocusScope.of(context).unfocus();

    final result = await ApiService.login(emailController.text.trim(), passController.text.trim());

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Login Failed"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- LOGO & TITLE ---
              const Icon(Icons.lock_open, size: 80, color: kPrimaryColor),
              const SizedBox(height: 15),
              const Text(
                "SYSTEM ACCESS",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    letterSpacing: 2.0
                ),
              ),
              const SizedBox(height: 40),

              // --- INPUT FIELDS ---
              HackerInput(
                  hintText: "Email Address",
                  icon: Icons.email,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress
              ),
              const SizedBox(height: 15),
              HackerInput(
                  hintText: "Password",
                  icon: Icons.key,
                  isObscure: true,
                  controller: passController
              ),

              const SizedBox(height: 25),

              // --- LOGIN BUTTON ---
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : HackerButton(
                text: "LOGIN SYSTEM",
                color: kBlueButtonColor, // নীল বাটন লগইনের জন্য
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 40),

              // --- DIVIDER DESIGN ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade800)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR", style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Courier')),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade800)),
                ],
              ),

              const SizedBox(height: 20),

              // --- REGISTRATION SECTION (DESIGNED FOR CUSTOMERS) ---
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "আপনার কি ইউজার একাউন্ট নেই?",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimaryColor, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add, color: kPrimaryColor, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "রেজিস্ট্রেশন করুন",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Courier'
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}