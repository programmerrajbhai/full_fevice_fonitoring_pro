import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ Emulator ব্যবহার করলে: "http://10.0.2.2/hacker_api/api"
  // ⚠️ Real Device ব্যবহার করলে: "http://YOUR_PC_IP_ADDRESS/hacker_api/api"
  statGot dependencies!
  6 packages have newer versions incompatible with dependency constraints.
  Try `flutter pub outdated` for more information.
  Running Gradle task 'assembleRelease'...      ic const String baseUrl = "https://8289-103-190-205-159.ngrok-free.app/hacker_api/api";
//https://8289-103-190-205-159.ngrok-free.app/hacker_api/api/
  // --- 1. REGISTER USER ---
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
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




  // --- 4. GET PROFILE DATA ---
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) return {"success": false, "message": "No user found"};

      final response = await http.post(
        Uri.parse("$baseUrl/get_profile.php"),
        body: jsonEncode({"user_id": userId}),
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Server Error"};
    }
  }

  // --- 5. BUY SUBSCRIPTION (MOCK) ---
  static Future<Map<String, dynamic>> upgradeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final response = await http.post(
        Uri.parse("$baseUrl/upgrade_subscription.php"),
        body: jsonEncode({"user_id": userId}),
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection Error"};
    }
  }

  // --- 6. SUBMIT MANUAL PAYMENT ---
  static Future<Map<String, dynamic>> submitPayment({
    required String method,
    required String amount,
    required String trxInfo,
    required String plan,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final response = await http.post(
        Uri.parse("$baseUrl/submit_payment.php"), // ফাইলের নাম চেঞ্জ হয়েছে
        body: jsonEncode({
          "user_id": userId,
          "payment_method": method,
          "amount": amount,
          "transaction_info": trxInfo,
          "plan_selected": plan
        }),
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection Error"};
    }
  }




}