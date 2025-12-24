import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

class AuthService {
  // Example: Login and save token
  // Replace with your actual API endpoint
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Replace with your actual login API URL
      final url = Uri.parse('https://bookify.happyeventsurat.com/api/login');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if login was successful and token exists
        if (data['status'] == 'success' && data['token'] != null) {
          // Save token to SharedPreferences
          await TokenManager.saveToken(data['token']);
          
          return {
            'success': true,
            'message': 'Login successful',
            'token': data['token'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Example: Save token directly (if you receive token from somewhere else)
  static Future<bool> saveTokenFromBackend(String token) async {
    return await TokenManager.saveToken(token);
  }

  // Logout - remove token
  static Future<bool> logout() async {
    return await TokenManager.removeToken();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await TokenManager.hasToken();
  }
}

