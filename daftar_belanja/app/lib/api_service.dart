import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class ApiService {
  static const String baseUrl = 'https://daftarbelanja.glitch.me/';

  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Save FCM token after successful registration
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await _saveFcmToken(username, fcmToken);
      return true;
    } else {
      return false;
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Save FCM token after successful login
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await _saveFcmToken(username, fcmToken);
      return {'success': true, 'token': fcmToken};
    } else {
      return {'success': false, 'token': null};
    }
  }

  static Future<void> _saveFcmToken(String username, String? token) async {
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/save-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'token': token}),
      );
    }
  }
}
