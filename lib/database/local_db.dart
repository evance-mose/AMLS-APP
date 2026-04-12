import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  LocalDb._();

  static Database? _db;
  static const _fileName = 'amls.db';
  static const _version = 1;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _fileName);
    _db = await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE issues_cache (
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  updated_at_ms INTEGER NOT NULL
)''');
        await db.execute('''
CREATE TABLE logs_cache (
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  updated_at_ms INTEGER NOT NULL
)''');
        await db.execute('''
CREATE TABLE sync_queue (
  local_id TEXT PRIMARY KEY,
  entity TEXT NOT NULL,
  operation TEXT NOT NULL,
  payload TEXT NOT NULL,
  server_id INTEGER,
  status TEXT NOT NULL DEFAULT 'pending',
  attempts INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  created_at INTEGER NOT NULL
)''');
      },
    );
    return _db!;
  }
}
