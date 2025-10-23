import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amls/models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Login with email and password
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Logging in with email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login?email=$email&password=$password'),
        headers: headers,
      );
      
      print('Login Response status: ${response.statusCode}');
      print('Login Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Extract token from response
        final String? token = responseData['token'] ?? responseData['access_token'];
        
        if (token == null) {
          throw Exception('No token received from server');
        }
        
        // Store token securely
        await _storeToken(token);
        
        // Extract user data if available
        if (responseData['user'] != null) {
          final user = User.fromJson(responseData['user']);
          await _storeUser(user);
          return {
            'token': token,
            'user': user,
            'success': true,
          };
        }
        
        return {
          'token': token,
          'success': true,
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Logout and clear stored data
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      print('Logged out successfully');
    } catch (e) {
      print('Logout Error: $e');
      throw Exception('Logout failed: $e');
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Get stored user data
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Store token securely
  static Future<void> _storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('Token stored successfully');
    } catch (e) {
      print('Error storing token: $e');
      throw Exception('Failed to store token: $e');
    }
  }

  // Store user data
  static Future<void> _storeUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
      print('User data stored successfully');
    } catch (e) {
      print('Error storing user: $e');
      throw Exception('Failed to store user data: $e');
    }
  }

  // Get headers with authorization token
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = Map<String, String>.from(AuthService.headers);
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
