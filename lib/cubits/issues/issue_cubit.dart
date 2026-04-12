import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/database/local_cache.dart';
import 'package:amls/database/storage_json.dart';
import 'package:amls/database/sync_queue.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/services/api_instances.dart';
import 'package:amls/services/api_service.dart';
import 'package:amls/services/sync_service.dart';

part 'issue_state.dart';

class IssueCubit extends Cubit<IssueState> {
  IssueCubit() : super(IssueInitial());

  Future<void> fetchIssues() async {
    final cached = await LocalCache.getIssues();
    if (cached.isNotEmpty) {
      emit(IssueLoaded(cached, fromCache: true));
    } else {
      emit(IssueLoading());
    }
    try {
      var fresh = await ApiInstances.issueApi.fetchAll();
      await LocalCache.replaceIssues(fresh);
      final processed = await SyncService.processPendingQueue();
      if (processed > 0) {
        fresh = await ApiInstances.issueApi.fetchAll();
        await LocalCache.replaceIssues(fresh);
      }
      emit(IssueLoaded(fresh, fromCache: false));
    } catch (e) {
      if (cached.isEmpty) {
        emit(IssueError('Error fetching issues: $e'));
      } else {
        emit(IssueLoaded(cached, fromCache: true));
      }
    }
  }

  Future<void> addLog(Issue log, {String? actionTaken}) async {
    emit(IssueLoading());
    try {
      await ApiService.createLog(log, actionTaken: actionTaken);
      await fetchIssues();
    } catch (e) {
      if (SyncService.looksLikeNetworkError(e)) {
        await SyncQueue.enqueue(
          entity: kSyncEntityIssueLog,
          operation: kSyncOpCreate,
          payloadJson: encodePayload({
            'issue': issueToStorageJson(log),
            'action_taken': actionTaken,
          }),
        );
        final cached = await LocalCache.getIssues();
        emit(IssueLoaded(cached, fromCache: true));
      } else {
        emit(IssueError('Error Assigning issue: $e'));
      }
    }
  }

  Future<void> addIssue(Issue issue) async {
    emit(IssueLoading());
    try {
      await ApiInstances.issueApi.create(issue);
      await fetchIssues();
    } catch (e) {
      if (SyncService.looksLikeNetworkError(e)) {
        await SyncQueue.enqueue(
          entity: kSyncEntityIssue,
          operation: kSyncOpCreate,
          payloadJson: encodePayload(issueToStorageJson(issue)),
        );
        final cached = await LocalCache.getIssues();
        emit(IssueLoaded(cached, fromCache: true));
      } else {
        emit(IssueError('Error adding issue: $e'));
      }
    }
  }

  Future<void> updateIssue(Issue oldIssue, Issue newIssue) async {
    emit(IssueLoading());
    try {
      await ApiInstances.issueApi.update(oldIssue.id, newIssue);
      await fetchIssues();
    } catch (e) {
      if (SyncService.looksLikeNetworkError(e)) {
        await SyncQueue.enqueue(
          entity: kSyncEntityIssue,
          operation: kSyncOpUpdate,
          payloadJson: encodePayload({
            'server_id': oldIssue.id,
            'issue': issueToStorageJson(newIssue),
          }),
          serverId: oldIssue.id,
        );
        final cached = await LocalCache.getIssues();
        emit(IssueLoaded(cached, fromCache: true));
      } else {
        emit(IssueError('Error updating issue: $e'));
      }
    }
  }

  Future<void> deleteIssue(Issue issue) async {
    emit(IssueLoading());
    try {
      await ApiInstances.issueApi.delete(issue.id);
      await fetchIssues();
    } catch (e) {
      if (SyncService.looksLikeNetworkError(e)) {
        await SyncQueue.enqueue(
          entity: kSyncEntityIssue,
          operation: kSyncOpDelete,
          payloadJson: encodePayload({'server_id': issue.id}),
          serverId: issue.id,
        );
        final cached = await LocalCache.getIssues();
        emit(IssueLoaded(cached, fromCache: true));
      } else {
        emit(IssueError('Error deleting issue: $e'));
      }
    }
  }
}
