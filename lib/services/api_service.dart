import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ Emulator ব্যবহার করলে: "http://10.0.2.2/hacker_api/api"
  // ⚠️ Real Device ব্যবহার করলে: "http://YOUR_PC_IP_ADDRESS/hacker_api/api"
  static const String baseUrl = "http://192.168.1.105/hacker_api/api";

  // --- 1. REGISTER USER ---
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.105/hacker_api/api/register.php"),
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
        headers: {"Content-Type": "application/json"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  // --- 2. LOGIN USER ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
        headers: {"Content-Type": "application/json"},
      );

      final data = jsonDecode(response.body);

      // যদি লগইন সফল হয়, ডাটা সেভ করে রাখব
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', data['user_id']);
        await prefs.setString('username', data['username']);
        await prefs.setBool('is_subscribed', data['is_subscribed']);
        await prefs.setBool('is_logged_in', true);
      }
      return data;
    } catch (e) {
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  // --- 3. GET DATA & CHECK SUBSCRIPTION ---
  static Future<Map<String, dynamic>> getData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) return {"success": false, "message": "No user found"};

      final response = await http.post(
        Uri.parse("$baseUrl/get_data.php"),
        body: jsonEncode({"user_id": userId}),
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection Error"};
    }
  }

  // --- LOGOUT ---
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // সব ডাটা মুছে ফেলবে
  }
}