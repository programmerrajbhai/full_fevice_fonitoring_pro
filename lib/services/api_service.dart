import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class ApiService {
  static const String baseUrl = "https://teamethicalcyberforce.com/hacker_api/api";

  // --- GET PAYMENT METHODS ---
  static Future<List<dynamic>> getPaymentMethods() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_payment_methods.php"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data']; // ডাটাবেস থেকে লিস্ট রিটার্ন করবে
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching methods: $e");
      return [];
    }
  }

  // --- 1. REGISTER API ---
  static Future<Map<String, dynamic>> register(String username, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "phone": phone,
          "password": password
        }),
      );

      debugPrint("Register Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Server Error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection Failed: $e"};
    }
  }

  // --- 2. LOGIN API ---
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "password": password
        }),
      );

      debugPrint("Login Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ লগইন সফল হলে সেশনে user_id এবং username সেভ করা হচ্ছে
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('username', data['username'] ?? "User");

          // 🔥 এই লাইনটি সবচেয়ে গুরুত্বপূর্ণ: user_id সেভ করা
          if (data['user_id'] != null) {
            await prefs.setString('user_id', data['user_id'].toString());
          }
        }

        return data;
      } else {
        return {"success": false, "message": "Server Error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection Failed: $e"};
    }
  }

  // --- 3. GET DATA ---
  static Future<Map<String, dynamic>> getData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString();

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

      // user_id int বা String যাই হোক না কেন, সেফলি হ্যান্ডেল করা হলো
      final userId = prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString();

      if (userId == null) return {"success": false, "message": "No user found in local storage"};

      final response = await http.post(
        Uri.parse("$baseUrl/get_profile.php"),
        body: jsonEncode({"user_id": userId}), // স্ট্রিং হিসেবে পাঠানো হচ্ছে
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("Profile Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Server Error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  // --- 5. UPGRADE SUBSCRIPTION ---
  static Future<Map<String, dynamic>> upgradeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString();

      if (userId == null) return {"success": false, "message": "No user found"};

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
      final userId = prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString();

      if (userId == null) return {"success": false, "message": "No user found"};

      final response = await http.post(
        Uri.parse("$baseUrl/submit_payment.php"),
        body: jsonEncode({
          "user_id": userId,
          "payment_method": method,
          "amount": amount,
          "transaction_info": trxInfo,
          "plan_selected": plan,
        }),
        headers: {"Content-Type": "application/json"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection Error"};
    }
  }
}