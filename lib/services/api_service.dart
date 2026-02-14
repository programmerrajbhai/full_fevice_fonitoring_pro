import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class ApiService {
  static const String baseUrl = "https://publishuapp.com/hacker_api/api";

  // --- 1. REGISTER USER ---
  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      debugPrint("Registering: $username, $email");

      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // ⚠️ নতুন হেডার যুক্ত করা হলো
        },
      );

      debugPrint("Register API Status: ${response.statusCode}");
      debugPrint(
        "Register API Body: '${response.body}'",
      ); // ⚠️ Body এর আগে-পিছে কিছু আছে কিনা দেখতে

      if (response.statusCode == 200) {
        // ⚠️ Safe JSON Decoding (যাতে Exception না আসে)
        try {
          return jsonDecode(response.body);
        } catch (e) {
          debugPrint("JSON Decode Error in Register: $e");
          return {
            "success": false,
            "message": "API Response Format Error. Check backend.",
          };
        }
      } else {
        return {
          "success": false,
          "message": "Server Error: ${response.statusCode}",
        };
      }
    } catch (e) {
      debugPrint("Register Exception: $e");
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  // --- 2. LOGIN USER ---
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      debugPrint("Logging in: $email");

      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: jsonEncode({"email": email, "password": password}),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // ⚠️ নতুন হেডার যুক্ত করা হলো
        },
      );

      debugPrint("Login API Status: ${response.statusCode}");
      debugPrint(
        "Login API Body: '${response.body}'",
      ); // ⚠️ Body এর আগে-পিছে কিছু আছে কিনা দেখতে

      if (response.statusCode == 200) {
        // ⚠️ Safe JSON Decoding
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          debugPrint("JSON Decode Error in Login: $e");
          return {
            "success": false,
            "message":
                "API Response Format Error. Server returning HTML or Spaces.",
          };
        }

        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();

          var userId = data['user_id'];
          if (userId is String) {
            await prefs.setInt('user_id', int.tryParse(userId) ?? 0);
          } else if (userId is int) {
            await prefs.setInt('user_id', userId);
          }

          await prefs.setString('username', data['username']);

          var isSub = data['is_subscribed'];
          bool subStatus = false;
          if (isSub is bool) subStatus = isSub;
          if (isSub is int) subStatus = (isSub == 1);

          await prefs.setBool('is_subscribed', subStatus);
          await prefs.setBool('is_logged_in', true);
        }
        return data;
      } else {
        return {
          "success": false,
          "message": "Server Error: ${response.statusCode}",
        };
      }
    } catch (e) {
      debugPrint("Login Exception: $e");
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  // ... (বাকি ফাংশনগুলো আগের মতোই থাকবে, তবে সেগুলোতেও "Accept": "application/json" হেডার দিতে পারেন)
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
