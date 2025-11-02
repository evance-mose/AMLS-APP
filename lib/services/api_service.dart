import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:amls/models/log_model.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/models/monthly_report_model.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/services/auth_service.dart';
// ignore: avoid_relative_lib_imports
import 'package:amls/services/base_url.dart';

class ApiService {
  
  static const Map<String, String> baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get headers with authentication token
  static Future<Map<String, String>> _getHeaders() async {
    final authHeaders = await AuthService.getAuthHeaders();
    return authHeaders;
  }

  // Fetch all logs
  static Future<List<Log>> fetchLogs() async {
    try {
      print('Fetching logs from: ${BaseUrl.baseUrl}/logs');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/logs'),
        headers: headers,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Parsed ${jsonData.length} logs');
        return jsonData.map((json) {
          try {
            return Log.fromJson(json);
          } catch (e) {
            print('Error parsing log: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to fetch logs: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error fetching logs: $e');
    }
  }

  // Create a new log
static Future<Issue> createLog(Issue log) async {
  try {
    // Convert enum values to lowercase strings matching Laravel validation
    String statusValue = log.status.name.toLowerCase(); // e.g., "pending", "in_progress"
    String priorityValue = log.priority.name.toLowerCase(); // e.g., "low", "medium", "high"
    
    // Handle if your enum uses camelCase (e.g., inProgress -> in_progress)
    statusValue = statusValue.replaceAllMapped(
      RegExp(r'([A-Z])'), 
      (match) => '_${match.group(0)!.toLowerCase()}'
    );
    
    Map<String, dynamic> newLog = {
      'user_id': log.userId,
      'issue_id': log.id,
      'action_taken': '',
      'status': statusValue,
      'priority': priorityValue,
    };
    
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/logs'),
      headers: headers,
      body: json.encode(newLog),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Issue.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create log: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Error creating log: $e');
  }
}
  // Update an existing log
  static Future<Log> updateLog(int id, Log log) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${BaseUrl.baseUrl}/logs/$id'),
        headers: headers,
        body: json.encode(log.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Log.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating log: $e');
    }
  }

  // Delete a log
  static Future<void> deleteLog(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}/logs/$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting log: $e');
    }
  }

  // Fetch all issues
  static Future<List<Issue>> fetchIssues() async {
    try {
      print('Fetching issues from: ${BaseUrl.baseUrl}/issues');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/issues'),
        headers: headers,
      );
      
      print('Issues Response status: ${response.statusCode}');
      print('Issues Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Parsed ${jsonData.length} issues');
        return jsonData.map((json) {
          try {
            return Issue.fromJson(json);
          } catch (e) {
            print('Error parsing issue: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to fetch issues: ${response.statusCode}');
      }
    } catch (e) {
      print('Issues API Error: $e');
      throw Exception('Error fetching issues: $e');
    }
  }

  // Create a new issue
  static Future<Issue> createIssue(Issue issue) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/issues'),
        headers: headers,
        body: json.encode(issue.toJson()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Issue.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create issue: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  // Update an existing issue
  static Future<Issue> updateIssue(int id, Issue issue) async {
    try {
      print('Update Issue Response body: ${issue.toJson()}');
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${BaseUrl.baseUrl}/issues/$id'),
        headers: headers,
        body: json.encode(issue.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Issue.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update issue: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating issue: $e');
    }
  }

  // Delete an issue
  static Future<void> deleteIssue(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}/issues/$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete issue: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting issue: $e');
    }
  }

  // Fetch monthly report
  static Future<MonthlyReport> fetchMonthlyReport() async {
    try {
      print('Fetching monthly report from: ${BaseUrl.baseUrl}/reports/monthly');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/analytics/monthly'),
        headers: headers,
      );
      
      print('Monthly Report Response status: ${response.statusCode}');
      print('Monthly Report Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Parsed monthly report data');
        return MonthlyReport.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch monthly report: ${response.statusCode}');
      }
    } catch (e) {
      print('Monthly Report API Error: $e');
      throw Exception('Error fetching monthly report: $e');
    }
  }

  // Fetch all users
  static Future<List<User>> fetchUsers() async {
    try {
      print('Fetching users from: ${BaseUrl.baseUrl}/users');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/users'),
        headers: headers,
      );
      
      print('Users Response status: ${response.statusCode}');
      print('Users Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Parsed ${jsonData.length} users');
        return jsonData.map((json) {
          try {
            return User.fromJson(json);
          } catch (e) {
            print('Error parsing user: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('Users API Error: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Create a new user
  static Future<User> createUser(User user) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/users'),
        headers: headers,
        body: json.encode(user.toJson()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // Update an existing user
  static Future<User> updateUser(int id, User user) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${BaseUrl.baseUrl}/users/$id'),
        headers: headers,
        body: json.encode(user.toJson()),
      );
      
      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Delete a user
  static Future<void> deleteUser(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}/users/$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
