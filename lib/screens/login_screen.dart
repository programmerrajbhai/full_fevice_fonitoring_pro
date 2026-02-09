import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
import '../services/api_service.dart'; // সার্ভিস ইম্পোর্ট
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
  bool isLoading = false; // লোডিং দেখানোর জন্য

  void _handleLogin() async {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true); // লোডিং শুরু

    final result = await ApiService.login(emailController.text, passController.text);

    setState(() => isLoading = false); // লোডিং শেষ

    if (result['success']) {
      // লগইন সফল
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
    } else {
      // লগইন ব্যর্থ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Login Failed"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_open, size: 80, color: kPrimaryColor),
              const SizedBox(height: 20),
              const Text(
                "HACKER LOGIN",
                style: TextStyle(color: kPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
              ),
              const SizedBox(height: 40),

              HackerInput(hintText: "Email", icon: Icons.email, controller: emailController, keyboardType: TextInputType.emailAddress),
              HackerInput(hintText: "Password", icon: Icons.key, isObscure: true, controller: passController),

              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator(color: kPrimaryColor)
                  : HackerButton(
                text: "ACCESS SYSTEM",
                color: kBlueButtonColor,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                },
                child: const Text("Join the Anonymous Legion? Register", style: TextStyle(color: Colors.white70, fontFamily: 'Courier')),
              )
            ],
          ),
        ),
      ),
    );
  }
}