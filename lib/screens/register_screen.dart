import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(backgroundColor: kBackgroundColor, iconTheme: const IconThemeData(color: kPrimaryColor)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("REGISTER", style: TextStyle(color: kPrimaryColor, fontSize: 24)),
            const SizedBox(height: 30),
            const HackerInput(hintText: "Username", icon: Icons.person),
            const HackerInput(hintText: "Email", icon: Icons.email),
            const HackerInput(hintText: "Password", icon: Icons.key, isObscure: true),
            const SizedBox(height: 20),
            HackerButton(
              text: "SIGN UP",
              color: kRedButtonColor,
              onPressed: () {
                Navigator.pop(context); // রেজিস্ট্রেশন শেষে লগইনে ফেরত যাবে
              },
            ),
          ],
        ),
      ),
    );
  }
}