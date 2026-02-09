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
    if (userController.text.isEmpty || emailController.text.isEmpty || passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All fields are required!")));
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.register(
        userController.text,
        emailController.text,
        passController.text
    );

    setState(() => isLoading = false);

    if (result['success']) {
      // সফল হলে ডায়লগ দেখিয়ে লগইন পেজে পাঠাবে
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: kPrimaryColor),
          title: const Text("SUCCESS", style: TextStyle(color: kPrimaryColor, fontFamily: 'Courier')),
          content: const Text("Identity Created. Please Login.", style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child: const Text("GO TO LOGIN"),
              onPressed: () {
                Navigator.pop(context); // ডায়লগ বন্ধ
                Navigator.pop(context); // লগইন পেজে ফেরত
              },
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("NEW IDENTITY", style: TextStyle(fontFamily: 'Courier', color: kPrimaryColor)),
        backgroundColor: kBackgroundColor,
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 60, color: kPrimaryColor),
              const SizedBox(height: 30),

              HackerInput(hintText: "Username", icon: Icons.person, controller: userController),
              HackerInput(hintText: "Email", icon: Icons.email, controller: emailController, keyboardType: TextInputType.emailAddress),
              HackerInput(hintText: "Password", icon: Icons.key, isObscure: true, controller: passController),

              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator(color: kPrimaryColor)
                  : HackerButton(
                text: "CREATE ACCOUNT",
                color: kRedButtonColor,
                onPressed: _handleRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}