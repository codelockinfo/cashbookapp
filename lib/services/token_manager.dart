import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'user_token';
  
  // Save token to SharedPreferences (Preference Manager)
  static Future<bool> saveToken(String token) async {
    try {
      print('💾 TokenManager: Saving token to SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(_tokenKey, token);
      
      if (result) {
        print('✅ TokenManager: Token saved successfully to SharedPreferences');
        // Verify it was saved
        final verifyToken = await prefs.getString(_tokenKey);
        if (verifyToken == token) {
          print('✅ TokenManager: Token verification successful - Token is stored correctly');
        } else {
          print('⚠️ TokenManager: Token verification failed - Token mismatch');
        }
      } else {
        print('❌ TokenManager: Failed to save token to SharedPreferences');
      }
      
      return result;
    } catch (e) {
      print('❌ TokenManager: Error saving token: $e');
      return false;
    }
  }
  
  // Get token from SharedPreferences (Preference Manager)
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token != null) {
        print('✅ TokenManager: Token retrieved from SharedPreferences (length: ${token.length})');
      } else {
        print('ℹ️ TokenManager: No token found in SharedPreferences');
      }
      
      return token;
    } catch (e) {
      print('❌ TokenManager: Error getting token: $e');
      return null;
    }
  }
  
  // Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Remove token (logout)
  static Future<bool> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      print('Error removing token: $e');
      return false;
    }
  }
  
  // Clear all preferences (optional)
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Error clearing preferences: $e');
      return false;
    }
  }
}

