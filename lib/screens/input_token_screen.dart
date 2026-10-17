import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hacker_button.dart';
import '../widgets/hacker_loading.dart';

class InputTokenScreen extends StatefulWidget {
  final String backgroundImage;
  const InputTokenScreen({super.key, required this.backgroundImage});

  @override
  State<InputTokenScreen> createState() => _InputTokenScreenState();
}

class _InputTokenScreenState extends State<InputTokenScreen> {
  final TextEditingController _targetController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  // --- Start Secure Analysis ---
  void _startAnalysis() async {
    if (_targetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid target ID or endpoint reference!"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    // পলিসি-সেফ টার্মিনাল লোডিং ডায়ালগ কল করা হচ্ছে
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const HackerLoading(message: "Initializing Diagnostic Protocol...", statusText: '',),
    );

    // ৫ সেকেন্ড সিমুলেশন প্রসেসিং
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      Navigator.pop(context); // Close Loading Dialog
      setState(() => _isAnalyzing = false);
      _showSuccessReportDialog();
    }
  }

  // --- Success Report Dialog ---
  void _showSuccessReportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.verified_outlined, color: Colors.green),
            SizedBox(width: 10),
            Text("Assessment Complete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          "Diagnostic scan completed successfully.\n\nNo critical security vulnerabilities or anomalies detected on the target endpoint. System status is stable.",
          style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Go back to Dashboard
            },
            child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Security Diagnostic Module",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: kCardColor,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TOP BANNER ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: kPrimaryColor, size: 32),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Endpoint Verification",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Input target parameter below to execute comprehensive diagnostic protocols.",
                          style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- INPUT CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TARGET REFERENCE",
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _targetController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Enter target ID, URL or phone...",
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      prefixIcon: const Icon(Icons.link, color: kPrimaryColor, size: 20),
                      filled: true,
                      fillColor: kBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- EXECUTE BUTTON ---
                  HackerButton(
                    text: _isAnalyzing ? "Executing Protocols..." : "Run Security Assessment",
                    color: kPrimaryColor,
                    onPressed: _isAnalyzing ? () {} : _startAnalysis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "SECURE ENCRYPTED ENVIRONMENT | v3.0",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}