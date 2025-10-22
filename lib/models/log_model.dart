import 'package:flutter/foundation.dart';

enum LogStatus { pending, in_progress, completed, resolved, closed }
enum LogPriority { low, medium, high }

class Log {
  final int id;
  final int? userId;
  final int? issueId;
  final String? actionTaken;
  final String atmId;
  final String location;
  final LogStatus status;
  final LogPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  Log({
    required this.id,
    this.userId,
    this.issueId,
    this.actionTaken,
    required this.atmId,
    required this.location,
    this.status = LogStatus.pending,
    this.priority = LogPriority.low,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      issueId: json['issue_id'] as int?,
      actionTaken: json['action_taken'] as String?,
      atmId: json['atm_id'] as String,
      location: json['location'] as String,
      status: LogStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => LogStatus.pending,
      ),
      priority: LogPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => LogPriority.low,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'issue_id': issueId,
      'action_taken': actionTaken,
      'atm_id': atmId,
      'location': location,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Log(id: $id, status: $status, priority: $priority)';
  }
}
