import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constants.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // --- ভিডিও লিস্ট (সঠিক ভিডিও আইডি ব্যবহার করবেন) ---
  final List<Map<String, String>> _videos = [
    {
      "title": "কিভাবে একাউন্ট খুলবেন?",
      "id": "iLnmTe5Q2Qw" // সঠিক ID
    },
    {
      "title": "সাবস্ক্রিপশন প্ল্যান কিভাবে নিবেন?",
      "id": "dQw4w9WgXcQ" // ডেমো ID (পরিবর্তন করে নিবেন)
    },
    {
      "title": "কিভাবে কানেকশন তৈরি করবেন?",
      "id": "M7lc1UVf-VE" // ডেমো ID (পরিবর্তন করে নিবেন)
    },
  ];

  Future<void> _openWhatsApp(String number) async {
    final Uri url = Uri.parse("https://wa.me/$number");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch WhatsApp")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SUPPORT & TUTORIALS", style: TextStyle(fontFamily: 'Courier', color: kPrimaryColor)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CONTACT SECTION ---
            const Text("📞 CONTACT SUPPORT", style: TextStyle(color: kPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
            const SizedBox(height: 10),

            _buildContactCard("Admin 1", "01333819608"),
            const SizedBox(height: 10),
            _buildContactCard("Admin 2", "01897737070"),

            const SizedBox(height: 30),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),

            // --- 2. VIDEO TUTORIAL SECTION ---
            const Text("🎬 VIDEO TUTORIALS", style: TextStyle(color: kPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
            const SizedBox(height: 15),

            // ভিডিও লিস্ট জেনারেট করা হচ্ছে
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // স্ক্রল যাতে প্যারেন্ট এর সাথে হয়
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                return VideoCardItem(
                  videoId: _videos[index]['id']!,
                  title: _videos[index]['title']!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(String title, String number) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(side: const BorderSide(color: kPrimaryColor), borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.chat, color: Colors.green, size: 30),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("WhatsApp: $number", style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: kPrimaryColor, size: 16),
        onTap: () => _openWhatsApp(number),
      ),
    );
  }
}

// ✅ আলাদা উইজেট বানানো হয়েছে মেমোরি লিক এবং ল্যাগ বন্ধ করার জন্য
class VideoCardItem extends StatefulWidget {
  final String videoId;
  final String title;

  const VideoCardItem({super.key, required this.videoId, required this.title});

  @override
  State<VideoCardItem> createState() => _VideoCardItemState();
}

class _VideoCardItemState extends State<VideoCardItem> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // কন্ট্রোলার একবারই ইনিশিয়ালাইজ হবে
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
        isLive: false,
        forceHD: false, // ল্যাগ কমানোর জন্য ফলস রাখা ভালো
      ),
    );
  }

  @override
  void deactivate() {
    // ভিডিও পজ করা যখন উইজেট স্ক্রিনে থাকবে না
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    // ⚠️ এই লাইনটি সবচেয়ে জরুরি: কন্ট্রোলার মেমোরি থেকে মুছে ফেলা
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: kPrimaryColor,
              bottomActions: [
                CurrentPosition(),
                ProgressBar(isExpanded: true, colors: const ProgressBarColors(playedColor: kPrimaryColor, handleColor: kPrimaryColor)),
                RemainingDuration(),
                const PlaybackSpeedButton(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}