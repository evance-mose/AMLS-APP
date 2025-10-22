import 'package:flutter/foundation.dart';

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

class Issue {
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
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int?,
      assignedTo: json['assigned_to'] as int?,
      location: json['location'] as String? ?? 'Unknown Location',
      atmId: json['atm_id'] as String? ?? 'Unknown ATM',
      category: IssueCategory.values.firstWhere(
        (e) => e.toString().split('.').last == (json['category'] as String? ?? 'other'),
        orElse: () => IssueCategory.other,
      ),
      description: json['description'] as String?,
      status: IssueStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String? ?? 'pending'),
        orElse: () => IssueStatus.pending,
      ),
      priority: IssuePriority.values.firstWhere(
        (e) => e.toString().split('.').last == (json['priority'] as String? ?? 'low'),
        orElse: () => IssuePriority.low,
      ),
      reportedDate: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'assigned_to': assignedTo,
      'location': location,
      'atm_id': atmId,
      'category': category.toString().split('.').last,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'reported_date': reportedDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Issue(id: $id, atmId: $atmId, location: $location, status: $status, priority: $priority)';
  }
}
