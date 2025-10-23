import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/models/log_model.dart';
import 'package:amls/services/api_instances.dart';

part 'log_state.dart';

class LogCubit extends Cubit<LogState> {
  LogCubit() : super(LogInitial());


  void fetchLogs() async {
    emit(LogLoading());
    
    try {
      final logs = await ApiInstances.logApi.fetchAll();
      emit(LogLoaded(logs));
    } catch (e) {
      emit(LogError('Error fetching logs: $e'));
    }
  }

  void addLog(Log log) async {
    emit(LogLoading());
    
    try {
      await ApiInstances.logApi.create(log);
      // Refresh the logs list after successful creation
      fetchLogs();
    } catch (e) {
      emit(LogError('Error adding log: $e'));
    }
  }

  void updateLog(Log oldLog, Log newLog) async {
    emit(LogLoading());
    
    try {
      await ApiInstances.logApi.update(oldLog.id, newLog);
      // Refresh the logs list after successful update
      fetchLogs();
    } catch (e) {
      emit(LogError('Error updating log: $e'));
    }
  }

  void deleteLog(Log log) async {
    emit(LogLoading());
    
    try {
      await ApiInstances.logApi.delete(log.id);
      // Refresh the logs list after successful deletion
      fetchLogs();
    } catch (e) {
      emit(LogError('Error deleting log: $e'));
    }
  }
}
