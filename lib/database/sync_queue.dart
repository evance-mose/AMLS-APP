import 'dart:math';

import 'package:sqflite/sqflite.dart';

import 'package:amls/database/local_db.dart';

const String kSyncEntityIssue = 'issue';
const String kSyncEntityLog = 'log';
const String kSyncEntityIssueLog = 'issue_log';
const String kSyncEntityLocationTrail = 'location_trail';

const String kSyncOpCreate = 'create';
const String kSyncOpUpdate = 'update';
const String kSyncOpDelete = 'delete';

const String kSyncStatusPending = 'pending';

class SyncQueue {
  SyncQueue._();

  static String _newLocalId() {
    final t = DateTime.now().microsecondsSinceEpoch;
    final r = Random().nextInt(0x7fffffff);
    return '${t}_$r';
  }

  static Future<String> enqueue({
    required String entity,
    required String operation,
    required String payloadJson,
    int? serverId,
  }) async {
    final db = await LocalDb.instance();
    final localId = _newLocalId();
    await db.insert(
      'sync_queue',
      {
        'local_id': localId,
        'entity': entity,
        'operation': operation,
        'payload': payloadJson,
        'server_id': serverId,
        'status': kSyncStatusPending,
        'attempts': 0,
        'last_error': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return localId;
  }

  static Future<int> pendingCount() async {
    final db = await LocalDb.instance();
    final r = await db.rawQuery(
      'SELECT COUNT(*) as c FROM sync_queue WHERE status = ?',
      [kSyncStatusPending],
    );
    return (r.first['c'] as int?) ?? 0;
  }
}
