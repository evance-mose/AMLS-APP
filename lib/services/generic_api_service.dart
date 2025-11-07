import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:amls/services/auth_service.dart';
// ignore: avoid_relative_lib_imports
import 'package:amls/services/base_url.dart';
import 'package:amls/models/issue_model.dart';

abstract class ApiModel {
  int get id;
  Map<String, dynamic> toJson();
}

class GenericApiService<T extends ApiModel> {
  
  static const Map<String, String> baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get headers with authentication token
  static Future<Map<String, String>> _getHeaders() async {
    final authHeaders = await AuthService.getAuthHeaders();
    return authHeaders;
  }

  final String endpoint;
  final T Function(Map<String, dynamic>) fromJson;

  GenericApiService({
    required this.endpoint,
    required this.fromJson,
  });

  // Fetch all items
  Future<List<T>> fetchAll() async {
    try {
      print('Fetching $endpoint from: ${BaseUrl.baseUrl}/$endpoint');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/$endpoint'),
        headers: headers,
      );
      
      print('$endpoint Response status: ${response.statusCode}');
      print('$endpoint Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Parsed ${jsonData.length} $endpoint');
        return jsonData.map((json) {
          try {
            return fromJson(json);
          } catch (e) {
            print('Error parsing $endpoint: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to fetch $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('$endpoint API Error: $e');
      throw Exception('Error fetching $endpoint: $e');
    }
  }

  // Create a new item
  Future<T> create(T item) async {
    try {
      final headers = await _getHeaders();
      // Handle Issue model specially to use forApi parameter
      Map<String, dynamic> jsonData;
      if (item is Issue) {
        jsonData = (item as Issue).toJson(forApi: true);
      } else {
        jsonData = item.toJson();
      }
      
      print('Creating $endpoint with data: $jsonData');
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/$endpoint'),
        headers: headers,
        body: json.encode(jsonData),
      );
      
      print('Create $endpoint response status: ${response.statusCode}');
      print('Create $endpoint response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return fromJson(responseData);
      } else {
        throw Exception('Failed to create $endpoint: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating $endpoint: $e');
    }
  }

  // Update an existing item
  Future<T> update(int id, T item) async {
    try {
      final headers = await _getHeaders();
      // Handle Issue model specially to use forApi parameter
      Map<String, dynamic> jsonData;
      if (item is Issue) {
        jsonData = (item as Issue).toJson(forApi: true);
      } else {
        jsonData = item.toJson();
      }
      
      print('Updating $endpoint $id with data: $jsonData');
      final response = await http.put(
        Uri.parse('${BaseUrl.baseUrl}/$endpoint/$id'),
        headers: headers,
        body: json.encode(jsonData),
      );
      
      print('Update $endpoint response status: ${response.statusCode}');
      print('Update $endpoint response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return fromJson(responseData);
      } else {
        throw Exception('Failed to update $endpoint: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating $endpoint: $e');
    }
  }

  // Delete an item
  Future<void> delete(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}/$endpoint/$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting $endpoint: $e');
    }
  }

  // Get a single item by ID
  Future<T> getById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/$endpoint/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching $endpoint: $e');
    }
  }
}
