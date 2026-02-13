import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';

class HackerLoading extends StatefulWidget {
  final String message;
  const HackerLoading({super.key, required this.message});

  @override
  State<HackerLoading> createState() => _HackerLoadingState();
}

class _HackerLoadingState extends State<HackerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _loadingText = "";
  int _dotCount = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);

    _startTextAnimation();
  }

  void _startTextAnimation() {
    _textTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
          _loadingText = widget.message + "." * _dotCount;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          border: Border.all(color: kPrimaryColor, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rotating/Pulsing Hacker Icon
            ScaleTransition(
              scale: _animation,
              child: const Icon(Icons.bug_report, size: 60, color: kPrimaryColor),
            ),
            const SizedBox(height: 20),

            // Animated Text
            Text(
              _loadingText,
              style: const TextStyle(
                color: kPrimaryColor,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Progress Bar
            const LinearProgressIndicator(
              backgroundColor: Colors.black,
              color: kPrimaryColor,
            ),
            const SizedBox(height: 10),
            const Text(
              "ENCRYPTING DATA...",
              style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Courier'),
            ),
          ],
        ),
      ),
    );
  }
}