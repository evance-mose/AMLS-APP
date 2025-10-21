import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'log_state.dart';

class LogCubit extends Cubit<LogState> {
  LogCubit() : super(LogInitial());

  final List<Map<String, dynamic>> _maintenanceLogs = [
    {
      'atmId': 'ATM-001',
      'location': 'Main Branch - Downtown',
      'date': '2024-10-20',
      'time': '14:30',
      'technician': 'Mike Johnson',
      'status': 'Completed',
      'type': 'Routine Check',
    },
    {
      'atmId': 'ATM-005',
      'location': 'Shopping Mall - East',
      'date': '2024-10-20',
      'time': '11:15',
      'technician': 'Sarah Williams',
      'status': 'In Progress',
      'type': 'Cash Replenishment',
    },
    {
      'atmId': 'ATM-012',
      'location': 'Airport Terminal 2',
      'date': '2024-10-19',
      'time': '09:00',
      'technician': 'David Brown',
      'status': 'Completed',
      'type': 'Hardware Repair',
    },
    {
      'atmId': 'ATM-008',
      'location': 'Central Market',
      'date': '2024-10-18',
      'time': '16:45',
      'technician': 'Mike Johnson',
      'status': 'Completed',
      'type': 'Software Update',
    },
    {
      'atmId': 'ATM-015',
      'location': 'Train Station',
      'date': '2024-10-18',
      'time': '10:20',
      'technician': 'Sarah Williams',
      'status': 'Completed',
      'type': 'Routine Check',
    },
  ];

  void fetchLogs() async {
    emit(LogLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    emit(LogLoaded(List.from(_maintenanceLogs)));
  }

  void addLog(Map<String, dynamic> log) async {
    emit(LogLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _maintenanceLogs.add(log);
    emit(LogLoaded(List.from(_maintenanceLogs)));
  }

  void updateLog(Map<String, dynamic> oldLog, Map<String, dynamic> newLog) async {
    emit(LogLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _maintenanceLogs.indexOf(oldLog);
    if (index != -1) {
      _maintenanceLogs[index] = newLog;
    }
    emit(LogLoaded(List.from(_maintenanceLogs)));
  }

  void deleteLog(Map<String, dynamic> log) async {
    emit(LogLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _maintenanceLogs.remove(log);
    emit(LogLoaded(List.from(_maintenanceLogs)));
  }
}
