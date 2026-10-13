import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';

class HackerLoading extends StatefulWidget {
  final String message;

  const HackerLoading({
    super.key,
    required this.message, required String statusText,
  });

  @override
  State<HackerLoading> createState() => _HackerLoadingState();
}

class _HackerLoadingState extends State<HackerLoading> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _logs = [];

  Timer? _blinkTimer;
  bool _showCursor = true;
  bool _isRunning = true;

  final Random _random = Random();

  // প্রোগ্রেস বারের জন্য ভেরিয়েবল
  bool _isProcessingBar = false;
  int _progress = 0;
  String _currentTask = "";

  @override
  void initState() {
    super.initState();
    // একদম রিয়েল টার্মিনাল ফিল দেওয়ার জন্য প্রথম লাইন
    _logs.add("root@security-audit:~\$ ${widget.message.isNotEmpty ? widget.message : './start_audit.sh'}");
    _logs.add("Initializing audit protocols...");

    _startCursorBlink();
    _startTerminalSimulation();
  }

  // --- ডায়নামিক রেন্ডম স্পিড জেনারেটর ---
  void _startTerminalSimulation() {
    _scheduleNextLog();
  }

  void _scheduleNextLog() {
    if (!mounted || !_isRunning) return;

    // টার্মিনালে ডাটা আসার স্পিড রেন্ডম করা হয়েছে (কখনো ফাস্ট, কখনো একটু আটকে আসবে)
    int nextDelay = _random.nextInt(250) + 50; // ৫০ থেকে ৩০০ মিলিসেকেন্ড

    Future.delayed(Duration(milliseconds: nextDelay), () {
      if (!mounted) return;
      _generateNextStep();
      _scrollToBottom();
      _scheduleNextLog();
    });
  }

  // --- টার্মিনালের আউটপুট জেনারেটর ---
  void _generateNextStep() {
    setState(() {
      if (_isProcessingBar) {
        // প্রোগ্রেস বার আপডেট হচ্ছে [######....]
        _progress += _random.nextInt(15) + 5; // ৫ থেকে ২০% করে বাড়বে
        if (_progress >= 100) {
          _progress = 100;
          _isProcessingBar = false; // প্রোগ্রেস কমপ্লিট হলে আবার নরমাল লগ শুরু হবে
        }

        int hashes = (_progress / 5).floor(); // মোট ২০টি # বসবে
        String bar = "#" * hashes + "." * (20 - hashes);

        // লিস্টের সর্বশেষ আইটেমটি আপডেট করা হচ্ছে যাতে একই লাইনে প্রোগ্রেস হয়
        _logs[_logs.length - 1] = "$_currentTask\n[$bar] $_progress%";

        if (_progress == 100) {
          _logs.add("> Task Completed Successfully.");
        }
      } else {
        // ২০% চান্স আছে নতুন একটি প্রোগ্রেস বার (####) শুরু হওয়ার
        if (_random.nextInt(100) < 20) {
          _isProcessingBar = true;
          _progress = 0;
          _currentTask = _getRandomTaskName();
          _logs.add("$_currentTask\n[....................] 0%");
        } else {
          // বাকি সময় নরমাল রেন্ডম লগ আসবে
          _logs.add(_generateDynamicLog());
        }
      }
    });
  }

  // রেন্ডম টাস্কের নাম (পলিসি সেফ)
  String _getRandomTaskName() {
    List<String> tasks = [
      "> Downloading encryption modules...",
      "> Decrypting local cached vault...",
      "> Auditing network packet integrity...",
      "> Extracting vulnerability report...",
      "> Validating node signatures..."
    ];
    return tasks[_random.nextInt(tasks.length)];
  }

  // রেন্ডম আইপি, হেক্স কোড এবং লগ (পলিসি সেফ)
  String _generateDynamicLog() {
    int type = _random.nextInt(7);
    String hex = (100000 + _random.nextInt(899999)).toRadixString(16).toUpperCase();
    String ip = "${_random.nextInt(255)}.${_random.nextInt(255)}.${_random.nextInt(255)}.${_random.nextInt(255)}";

    switch (type) {
      case 0: return "> Scanning proxy node: $ip ... [ OK ]";
      case 1: return "> Parsing binary block 0x$hex ...";
      case 2: return "> Establishing SSL handshake with node-${_random.nextInt(99)}";
      case 3: return "> DATA STREAM: 0x$hex 0x${(1000+_random.nextInt(8000)).toRadixString(16).toUpperCase()}";
      case 4: return "> Validating packet signature for secure access...";
      case 5: return "WARNING: High latency detected at $ip, rerouting traffic...";
      default: return "> Fetching encrypted tables from sys_db_$hex";
    }
  }

  // রিয়েলিস্টিক কার্সর ব্লিঙ্কিং (_)
  void _startCursorBlink() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  // অটোমেটিক নিচে স্ক্রল করার ফাংশন
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        // টার্মিনালের মতো সাডেন (Sudden) স্ক্রল করার জন্য jumpTo ব্যবহার করা হয়েছে
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _isRunning = false;
    _blinkTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        height: 500, // টার্মিনালের জন্য পারফেক্ট সাইজ
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A), // পিয়োর টার্মিনাল ব্ল্যাক
          border: Border.all(color: kPrimaryColor.withOpacity(0.5), width: 1.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Mac/Linux Style Terminal Window Header ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      _buildWindowDot(Colors.redAccent),
                      const SizedBox(width: 6),
                      _buildWindowDot(Colors.amber),
                      const SizedBox(width: 6),
                      _buildWindowDot(Colors.green),
                    ],
                  ),
                  const Expanded(
                    child: Text(
                      "root@system-audit:~",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 45), // টাইটেলকে মাঝে রাখার জন্য ব্যালেন্স
                ],
              ),
            ),

            // --- Terminal Output (Scrolling Text) ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    bool isLast = index == _logs.length - 1;
                    String logText = _logs[index];

                    // শেষ লাইনে ব্লিঙ্কিং কার্সর (_) যুক্ত করা হচ্ছে
                    if (isLast && _showCursor && !_isProcessingBar) {
                      logText += "_";
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        logText,
                        style: TextStyle(
                          // রিয়েল টার্মিনাল ফিল দেওয়ার জন্য নিয়ন গ্রিন কালার
                          color: logText.contains("WARNING") ? Colors.amber : Colors.greenAccent.shade400,
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // উইন্ডোর উপরের লাল, হলুদ, সবুজ ডট বানানোর ফাংশন
  Widget _buildWindowDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}