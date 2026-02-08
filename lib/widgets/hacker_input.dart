import 'package:flutter/material.dart';
import '../constants.dart';

class HackerInput extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final bool isObscure;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? prefixText;

  const HackerInput({
    super.key,
    required this.hintText,
    this.icon,
    this.isObscure = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: kPrimaryColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: kCardColor,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          prefixIcon: icon != null ? Icon(icon, color: kPrimaryColor) : null,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}