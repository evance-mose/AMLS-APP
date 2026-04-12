import 'dart:convert';

import 'package:amls/models/issue_model.dart';
import 'package:amls/models/log_model.dart';

/// JSON maps compatible with [Issue.fromJson] / [Log.fromJson].
Map<String, dynamic> issueToStorageJson(Issue issue) {
  return {
    'id': issue.id,
    'user_id': issue.userId,
    'assigned_to': issue.assignedTo,
    'location': issue.location,
    'atm_id': issue.atmId,
    'category': issue.category.toString().split('.').last,
    'description': issue.description,
    'status': issue.status.toString().split('.').last,
    'priority': issue.priority.toString().split('.').last,
    'created_at': issue.createdAt.toIso8601String(),
    'updated_at': issue.updatedAt.toIso8601String(),
    if (issue.user != null) 'user': issue.user!.toJson(),
    if (issue.assignedUser != null) 'assigned_user': issue.assignedUser!.toJson(),
  };
}

Map<String, dynamic> logToStorageJson(Log log) {
  return {
    'id': log.id,
    'user_id': log.userId,
    'issue_id': log.issueId,
    'action_taken': log.actionTaken,
    'category': log.category.toString().split('.').last,
    'status': log.status.toString().split('.').last,
    'priority': log.priority.toString().split('.').last,
    'created_at': log.createdAt.toIso8601String(),
    'updated_at': log.updatedAt.toIso8601String(),
    if (log.user != null) 'user': log.user!.toJson(),
    if (log.issue != null) 'issue': issueToStorageJson(log.issue!),
  };
}

String encodePayload(Map<String, dynamic> map) => jsonEncode(map);

Map<String, dynamic> decodePayload(String raw) =>
    Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>);
