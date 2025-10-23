import 'package:flutter/foundation.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/services/generic_api_service.dart';

enum LogStatus { pending, in_progress, completed, resolved, closed }
enum LogPriority { low, medium, high }
enum LogCategory { dispenser_errors, card_reader_errors, receipt_printer_errors, epp_errors, pc_core_errors, journal_printer_errors, recycling_module_errors, other }

class Log implements ApiModel {
  final int id;
  final int userId;
  final int? issueId;
  final String? actionTaken;
  final LogCategory category;
  final LogStatus status;
  final LogPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final Issue? issue;

  Log({
    required this.id,
    required this.userId,
    this.issueId,
    this.actionTaken,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.issue,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      issueId: json['issue_id'] as int?,
      actionTaken: json['action_taken'] as String?,
      category: LogCategory.values.firstWhere(
        (e) => e.toString().split('.').last == (json['category'] as String? ?? 'other'),
        orElse: () => LogCategory.other,
      ),
      status: LogStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String? ?? 'pending'),
        orElse: () => LogStatus.pending,
      ),
      priority: LogPriority.values.firstWhere(
        (e) => e.toString().split('.').last == (json['priority'] as String? ?? 'low'),
        orElse: () => LogPriority.low,
      ),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      issue: json['issue'] != null ? Issue.fromJson(json['issue']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'issue_id': issueId,
      'action_taken': actionTaken,
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'issue': issue?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Log(id: $id, status: $status, priority: $priority)';
  }
}
