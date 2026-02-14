import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool isLoading = false;

  void _handleRegister() async {
    if (userController.text.trim().isEmpty || emailController.text.trim().isEmpty || passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields are required!"), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() => isLoading = true);

    // কিবোর্ড নামিয়ে দেওয়ার জন্য
    FocusScope.of(context).unfocus();

    final result = await ApiService.register(
        userController.text.trim(),
        emailController.text.trim(),
        passController.text.trim()
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: kPrimaryColor, width: 2),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: kPrimaryColor),
              SizedBox(width: 10),
              Text("SUCCESS", style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Identity Created Successfully.\nPlease Login to continue.", style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: kPrimaryColor.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: const BorderSide(color: kPrimaryColor),
              ),
              child: const Text("GO TO LOGIN", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context); // ডায়লগ বন্ধ
                Navigator.pop(context); // লগইন পেজে ফেরত
              },
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Registration Failed"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("NEW IDENTITY", style: TextStyle(fontFamily: 'Courier', color: kPrimaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kPrimaryColor),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- ICON & TITLE ---
              const Icon(Icons.person_add, size: 80, color: kPrimaryColor),
              const SizedBox(height: 15),
              const Text(
                "CREATE ACCESS",
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

              // --- INPUTS ---
              HackerInput(hintText: "Username", icon: Icons.person, controller: userController),
              const SizedBox(height: 15),
              HackerInput(hintText: "Email Address", icon: Icons.email, controller: emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              HackerInput(hintText: "Password", icon: Icons.key, isObscure: true, controller: passController),

              const SizedBox(height: 25),

              // --- BUTTON ---
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : HackerButton(
                text: "INITIATE REGISTRATION",
                color: kRedButtonColor,
                onPressed: _handleRegister,
              ),

              const SizedBox(height: 40),

              // --- DIVIDER ---
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

              // --- LOGIN LINK SECTION ---
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
                      "আপনার কি ইতিমধ্যে একাউন্ট আছে?",
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
                          Navigator.pop(context); // Go back to Login
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: kPrimaryColor, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "লগইন করুন",
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