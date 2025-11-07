import 'package:flutter/foundation.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/services/generic_api_service.dart';

enum IssueCategory {
  dispenser_errors,
  card_reader_errors,
  receipt_printer_errors,
  epp_errors,
  pc_core_errors,
  journal_printer_errors,
  recycling_module_errors,
  other,
}
enum IssueStatus { pending, open, in_progress, assigned, acknowledged, resolved, closed }
enum IssuePriority { low, medium, high, critical }

class Issue implements ApiModel {
  final int id;
  final int? userId;
  final int? assignedTo;
  final String location;
  final String atmId;
  final IssueCategory category;
  final String? description;
  final IssueStatus status;
  final IssuePriority priority;
  final DateTime reportedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final User? assignedUser;

  Issue({
    required this.id,
    this.userId,
    this.assignedTo,
    required this.location,
    required this.atmId,
    required this.category,
    this.description,
    this.status = IssueStatus.pending,
    this.priority = IssuePriority.low,
    required this.reportedDate,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.assignedUser,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    // Handle nested issue structure (when response contains issue inside log or other structure)
    Map<String, dynamic> issueData = json;
    if (json.containsKey('issue') && json['issue'] is Map<String, dynamic>) {
      issueData = json['issue'] as Map<String, dynamic>;
    }
    
    return Issue(
      id: issueData['id'] as int? ?? 0,
      userId: issueData['user_id'] as int?,
      assignedTo: issueData['assigned_to'] as int?,
      location: issueData['location'] as String? ?? 'Unknown Location',
      atmId: issueData['atm_id'] as String? ?? 'Unknown ATM',
      category: IssueCategory.values.firstWhere(
        (e) => e.toString().split('.').last == (issueData['category'] as String? ?? 'other'),
        orElse: () => IssueCategory.other,
      ),
      description: issueData['description'] as String?,
      status: IssueStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (issueData['status'] as String? ?? 'pending'),
        orElse: () => IssueStatus.pending,
      ),
      priority: IssuePriority.values.firstWhere(
        (e) => e.toString().split('.').last == (issueData['priority'] as String? ?? 'low'),
        orElse: () => IssuePriority.low,
      ),
      reportedDate: issueData['created_at'] != null 
          ? DateTime.parse(issueData['created_at'] as String)
          : DateTime.now(),
      createdAt: issueData['created_at'] != null 
          ? DateTime.parse(issueData['created_at'] as String)
          : DateTime.now(),
      updatedAt: issueData['updated_at'] != null 
          ? DateTime.parse(issueData['updated_at'] as String)
          : DateTime.now(),
      user: issueData['user'] != null ? User.fromJson(issueData['user']) : null,
      assignedUser: issueData['assigned_user'] != null ? User.fromJson(issueData['assigned_user']) : null,
    );
  }

  Map<String, dynamic> toJson({bool forApi = false}) {
    // When sending to API, only send fields that backend expects
    if (forApi) {
      // Backend validation expects ONLY these fields:
      // 'location' => 'required|string|max:255'
      // 'atm_id' => 'required|string|max:255'
      // 'category' => 'required|in:dispenser_errors,card_reader_errors,receipt_printer_errors,epp_errors,pc_core_errors,journal_printer_errors,recycling_module_errors,other'
      // 'description' => 'nullable|string'
      // 'status' => 'required|in:pending,in_progress,resolved,closed'
      // 'priority' => 'required|in:low,medium,high'
      // 'assigned_to' => 'nullable|exists:users,id'
      
      // Map status to backend-accepted values (pending, in_progress, resolved, closed)
      String statusValue = status.toString().split('.').last;
      // Convert frontend statuses to backend-accepted ones
      if (statusValue == 'open' || statusValue == 'assigned' || statusValue == 'acknowledged') {
        statusValue = 'pending'; // Default to pending for unsupported statuses
      }
      // Ensure status is one of the valid values
      if (!['pending', 'in_progress', 'resolved', 'closed'].contains(statusValue)) {
        statusValue = 'pending';
      }
      
      // Map priority to backend-accepted values (low, medium, high)
      String priorityValue = priority.toString().split('.').last;
      if (priorityValue == 'critical') {
        priorityValue = 'high'; // Map critical to high
      }
      // Ensure priority is one of the valid values
      if (!['low', 'medium', 'high'].contains(priorityValue)) {
        priorityValue = 'low';
      }
      
      // Build the payload with ONLY the required fields
      final Map<String, dynamic> payload = {
        'location': location,
        'atm_id': atmId,
        'category': category.toString().split('.').last,
        'status': statusValue,
        'priority': priorityValue,
      };
      
      // Add nullable fields only if they have values
      if (description != null && description!.isNotEmpty) {
        payload['description'] = description;
      }
      
      if (assignedTo != null) {
        payload['assigned_to'] = assignedTo;
      }
      
      return payload;
    }
    
    // Full JSON for internal use
    return {
      'assigned_to': assignedTo,
      'location': location,
      'atm_id': atmId,
      'category': category.toString().split('.').last,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
    };
  }

  @override
  String toString() {
    return 'Issue(id: $id, atmId: $atmId, location: $location, status: $status, priority: $priority)';
  }
}
