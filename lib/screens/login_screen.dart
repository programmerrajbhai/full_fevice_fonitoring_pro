import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_input.dart';
import '../widgets/hacker_button.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_open, size: 80, color: kPrimaryColor),
            const SizedBox(height: 20),
            const Text(
              "HACKER LOGIN",
              style: TextStyle(color: kPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const HackerInput(hintText: "Username", icon: Icons.person),
            const HackerInput(hintText: "Password", icon: Icons.key, isObscure: true),
            const SizedBox(height: 20),
            HackerButton(
              text: "LOGIN",
              color: kBlueButtonColor,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
              },
              child: const Text("Create Account", style: TextStyle(color: Colors.white70)),
            )
          ],
        ),
      ),
    );
  }
}