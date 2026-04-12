import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:amls/database/local_db.dart';
import 'package:amls/database/storage_json.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/models/log_model.dart';

class LocalCache {
  LocalCache._();

  static Future<void> replaceIssues(List<Issue> issues) async {
    final db = await LocalDb.instance();
    await db.transaction((txn) async {
      await txn.delete('issues_cache');
      final batch = txn.batch();
      for (final issue in issues) {
        batch.insert(
          'issues_cache',
          {
            'id': issue.id,
            'payload': encodePayload(issueToStorageJson(issue)),
            'updated_at_ms': issue.updatedAt.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  static Future<List<Issue>> getIssues() async {
    final db = await LocalDb.instance();
    final rows = await db.query('issues_cache', orderBy: 'updated_at_ms DESC');
    final out = <Issue>[];
    for (final row in rows) {
      try {
        final map = jsonDecode(row['payload']! as String) as Map<String, dynamic>;
        out.add(Issue.fromJson(map));
      } catch (_) {
        continue;
      }
    }
    return out;
  }

  static Future<void> replaceLogs(List<Log> logs) async {
    final db = await LocalDb.instance();
    await db.transaction((txn) async {
      await txn.delete('logs_cache');
      final batch = txn.batch();
      for (final log in logs) {
        batch.insert(
          'logs_cache',
          {
            'id': log.id,
            'payload': encodePayload(logToStorageJson(log)),
            'updated_at_ms': log.updatedAt.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  static Future<List<Log>> getLogs() async {
    final db = await LocalDb.instance();
    final rows = await db.query('logs_cache', orderBy: 'updated_at_ms DESC');
    final out = <Log>[];
    for (final row in rows) {
      try {
        final map = jsonDecode(row['payload']! as String) as Map<String, dynamic>;
        out.add(Log.fromJson(map));
      } catch (_) {
        continue;
      }
    }
    return out;
  }
}
