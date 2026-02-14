import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class ApiService {
  static const String baseUrl = "https://publishuapp.com/hacker_api/api";

  // --- 1. REGISTER USER ---
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      debugPrint("Registering: $username, $email"); // Debug Log

      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("Register Response: ${response.body}"); // Server response check

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Server Error: ${response.statusCode}"};
      }
    } catch (e) {
      debugPrint("Register Error: $e");
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  // --- 2. LOGIN USER ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint("Logging in: $email");

      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("Login Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();

          // ⚠️ FIX: user_id স্ট্রিং বা ইনট যাই আসুক, হ্যান্ডেল করা হবে
          var userId = data['user_id'];
          if (userId is String) {
            await prefs.setInt('user_id', int.tryParse(userId) ?? 0);
          } else if (userId is int) {
            await prefs.setInt('user_id', userId);
          }

          await prefs.setString('username', data['username']);

          // ⚠️ FIX: is_subscribed হ্যান্ডলিং
          var isSub = data['is_subscribed'];
          bool subStatus = false;
          if (isSub is bool) subStatus = isSub;
          if (isSub is int) subStatus = (isSub == 1);

          await prefs.setBool('is_subscribed', subStatus);
          await prefs.setBool('is_logged_in', true);
        }
        return data;
      } else {
        return {"success": false, "message": "Server Error: ${response.statusCode}"};
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  // --- 3. GET DATA ---
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

  // --- 4. GET PROFILE ---
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

  // --- 5. UPGRADE SUBSCRIPTION ---
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

  // --- 6. SUBMIT PAYMENT ---
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
        Uri.parse("$baseUrl/submit_payment.php"),
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