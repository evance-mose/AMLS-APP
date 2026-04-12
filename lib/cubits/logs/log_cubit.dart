import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/database/local_cache.dart';
import 'package:amls/database/storage_json.dart';
import 'package:amls/database/sync_queue.dart';
import 'package:amls/models/log_model.dart';
import 'package:amls/services/api_instances.dart';
import 'package:amls/services/sync_service.dart';

part 'log_state.dart';

class LogCubit extends Cubit<LogState> {
  LogCubit() : super(LogInitial());

  Future<void> fetchLogs() async {
    final cached = await LocalCache.getLogs();
    if (cached.isNotEmpty) {
      emit(LogLoaded(cached, fromCache: true));
    } else {
      emit(LogLoading());
    }
    try {
      var fresh = await ApiInstances.logApi.fetchAll();
      await LocalCache.replaceLogs(fresh);
      final processed = await SyncService.processPendingQueue();
      if (processed > 0) {
        fresh = await ApiInstances.logApi.fetchAll();
        await LocalCache.replaceLogs(fresh);
      }
      emit(LogLoaded(fresh, fromCache: false));
    } catch (e) {
      if (cached.isEmpty) {
        emit(LogError('Error fetching logs: $e'));
      } else {
        emit(LogLoaded(cached, fromCache: true));
      }
    }
  }

  Future<void> addLog(Log log) async {
    emit(LogLoading());
    try {
      await ApiInstances.logApi.create(log);
      await fetchLogs();
    } catch (e) {
      if (SyncService.looksLikeNetworkError(e)) {
        await SyncQueue.enqueue(
          entity: kSyncEntityLog,
          operation: kSyncOpCreate,
          payloadJson: encodePayload(logToStorageJson(log)),
        );
        final cached = await LocalCache.getLogs();
        emit(LogLoaded(cached, fromCache: true));
      } else {
        emit(LogError('Error adding log: $e'));
      }
    }
  }

  Future<void> updateLog(Log oldLog, Log newLog) async {
    emit(LogLoading());
    try {
      await ApiInstances.logApi.update(oldLog.id, newLog);
      await fetchLogs();
    } catch (e) {
      if (SyncService.looksLikeNetworkError(e)) {
        await SyncQueue.enqueue(
          entity: kSyncEntityLog,
          operation: kSyncOpUpdate,
          payloadJson: encodePayload({
            'server_id': oldLog.id,
            'log': logToStorageJson(newLog),
          }),
          serverId: oldLog.id,
        );
        final cached = await LocalCache.getLogs();
        emit(LogLoaded(cached, fromCache: true));
      } else {
        emit(LogError('Error updating log: $e'));
      }
    }
  }

  Future<void> deleteLog(Log log) async {
    emit(LogLoading());
    try {
      await ApiInstances.logApi.delete(log.id);
      await fetchLogs();
    } catch (e) {
      if (SyncService.looksLikeNetworkError(e)) {
        await SyncQueue.enqueue(
          entity: kSyncEntityLog,
          operation: kSyncOpDelete,
          payloadJson: encodePayload({'server_id': log.id}),
          serverId: log.id,
        );
        final cached = await LocalCache.getLogs();
        emit(LogLoaded(cached, fromCache: true));
      } else {
        emit(LogError('Error deleting log: $e'));
      }
    }
  }
}
