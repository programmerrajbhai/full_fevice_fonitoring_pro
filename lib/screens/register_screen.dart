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
  final TextEditingController nameController = TextEditingController(); // ✅ Changed to nameController
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool isLoading = false;

  void _handleRegister() async {
    if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty || passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("সবগুলো ফিল্ড পূরণ করুন!"), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() => isLoading = true);
    FocusScope.of(context).unfocus();

    // ✅ nameController এর ডাটা পাঠানো হচ্ছে
    final result = await ApiService.register(
        nameController.text.trim(),
        phoneController.text.trim(),
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
              Text("SUCCESS", style: TextStyle(color: kPrimaryColor, fontFamily: kGlobalFont, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Identity Created Successfully.\nলগইন করে ব্যবহার শুরু করুন।", style: TextStyle(color: Colors.white, fontFamily: kGlobalFont)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: kPrimaryColor.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: const BorderSide(color: kPrimaryColor),
              ),
              child: const Text("GO TO LOGIN", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
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
        title: const Text("NEW IDENTITY", style: TextStyle(fontFamily: kGlobalFont, color: kPrimaryColor, fontWeight: FontWeight.bold)),
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
              const Icon(Icons.person_add, size: 80, color: kPrimaryColor),
              const SizedBox(height: 15),
              const Text(
                "CREATE ACCESS",
                textAlign: TextAlign.center,
                style: TextStyle(color: kPrimaryColor, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: kGlobalFont, letterSpacing: 2.0),
              ),
              const SizedBox(height: 40),

              // ✅ Full Name Input
              HackerInput(
                hintText: "Enter Username",
                icon: Icons.person,
                controller: nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 15),
              HackerInput(
                  hintText: "Phone Number (ফোন নম্বর)",
                  icon: Icons.phone_android,
                  controller: phoneController,
                  keyboardType: TextInputType.phone
              ),
              const SizedBox(height: 15),
              HackerInput(
                  hintText: "Password (পাসওয়ার্ড)",
                  icon: Icons.key,
                  isObscure: true,
                  controller: passController
              ),

              const SizedBox(height: 25),

              isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : HackerButton(text: "INITIATE REGISTRATION", color: kRedButtonColor, onPressed: _handleRegister),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade800)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR", style: TextStyle(color: Colors.grey.shade600, fontFamily: kGlobalFont)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade800)),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text("আপনার কি ইতিমধ্যে একাউন্ট আছে?", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimaryColor, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: kPrimaryColor, size: 18),
                            SizedBox(width: 8),
                            Text("লগইন করুন", style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: kGlobalFont)),
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