import 'package:amls/database/local_db.dart';
import 'package:amls/database/storage_json.dart';
import 'package:amls/database/sync_queue.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/models/log_model.dart';
import 'package:amls/services/api_instances.dart';
import 'package:amls/services/api_service.dart';

class SyncService {
  SyncService._();

  static Future<int>? _queueRun;

  static bool looksLikeNetworkError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('socketexception') ||
        s.contains('failed host lookup') ||
        s.contains('clientexception') ||
        s.contains('network is unreachable') ||
        s.contains('connection refused') ||
        s.contains('connection reset') ||
        s.contains('timed out') ||
        s.contains('handshake exception');
  }

  /// Returns how many queued operations completed successfully.
  /// Concurrent callers share one run so the same row is not applied twice.
  static Future<int> processPendingQueue() {
    if (_queueRun != null) return _queueRun!;
    _queueRun = _processPendingQueueImpl().whenComplete(() => _queueRun = null);
    return _queueRun!;
  }

  static Future<int> _processPendingQueueImpl() async {
    final db = await LocalDb.instance();
    final rows = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [kSyncStatusPending],
      orderBy: 'created_at ASC',
    );
    var completed = 0;
    for (final row in rows) {
      final localId = row['local_id']! as String;
      final entity = row['entity']! as String;
      final operation = row['operation']! as String;
      final payload = row['payload']! as String;
      try {
        await _applyOne(entity, operation, payload);
        await db.delete('sync_queue', where: 'local_id = ?', whereArgs: [localId]);
        completed++;
      } catch (e) {
        final attempts = (row['attempts'] as int? ?? 0) + 1;
        await db.update(
          'sync_queue',
          {
            'attempts': attempts,
            'last_error': e.toString(),
          },
          where: 'local_id = ?',
          whereArgs: [localId],
        );
        if (looksLikeNetworkError(e)) {
          break;
        }
      }
    }
    return completed;
  }

  static Future<void> _applyOne(String entity, String operation, String payload) async {
    final map = decodePayload(payload);
    if (entity == kSyncEntityIssue) {
      if (operation == kSyncOpCreate) {
        await ApiInstances.issueApi.create(Issue.fromJson(map));
        return;
      }
      if (operation == kSyncOpUpdate) {
        final id = map['server_id'] as int;
        final issueMap = Map<String, dynamic>.from(map['issue'] as Map<dynamic, dynamic>);
        await ApiInstances.issueApi.update(id, Issue.fromJson(issueMap));
        return;
      }
      if (operation == kSyncOpDelete) {
        final id = map['server_id'] as int;
        await ApiInstances.issueApi.delete(id);
        return;
      }
    }
    if (entity == kSyncEntityLog) {
      if (operation == kSyncOpCreate) {
        await ApiInstances.logApi.create(Log.fromJson(map));
        return;
      }
      if (operation == kSyncOpUpdate) {
        final id = map['server_id'] as int;
        final logMap = Map<String, dynamic>.from(map['log'] as Map<dynamic, dynamic>);
        await ApiInstances.logApi.update(id, Log.fromJson(logMap));
        return;
      }
      if (operation == kSyncOpDelete) {
        final id = map['server_id'] as int;
        await ApiInstances.logApi.delete(id);
        return;
      }
    }
    if (entity == kSyncEntityIssueLog && operation == kSyncOpCreate) {
      final issueMap = Map<String, dynamic>.from(map['issue'] as Map<dynamic, dynamic>);
      final action = map['action_taken'] as String?;
      await ApiService.createLog(Issue.fromJson(issueMap), actionTaken: action);
    }
    if (entity == kSyncEntityLocationTrail && operation == kSyncOpCreate) {
      await ApiService.submitLocationTrailPoint(
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        accuracyMeters: (map['accuracy_meters'] as num).toDouble(),
        recordedAt: DateTime.parse(map['recorded_at'] as String).toUtc(),
      );
    }
  }
}
