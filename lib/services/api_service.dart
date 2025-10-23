import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:amls/models/log_model.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/models/monthly_report_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Fetch all logs
  static Future<List<Log>> fetchLogs() async {
    try {
      print('Fetching logs from: $baseUrl/logs');
      final response = await http.get(
        Uri.parse('$baseUrl/logs'),
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
  static Future<Log> createLog(Log log) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logs'),
        headers: headers,
        body: json.encode(log.toJson()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Log.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating log: $e');
    }
  }

  // Update an existing log
  static Future<Log> updateLog(int id, Log log) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/logs/$id'),
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
      final response = await http.delete(
        Uri.parse('$baseUrl/logs/$id'),
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
      print('Fetching issues from: $baseUrl/issues');
      final response = await http.get(
        Uri.parse('$baseUrl/issues'),
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
      final response = await http.post(
        Uri.parse('$baseUrl/issues'),
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
      final response = await http.put(
        Uri.parse('$baseUrl/issues/$id'),
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
      final response = await http.delete(
        Uri.parse('$baseUrl/issues/$id'),
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
      print('Fetching monthly report from: $baseUrl/reports/monthly');
      final response = await http.get(
        Uri.parse('$baseUrl/reports/monthly'),
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
}
