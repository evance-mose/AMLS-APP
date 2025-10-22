import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/models/log_model.dart'; // Import the Log model

part 'log_state.dart';

class LogCubit extends Cubit<LogState> {
  LogCubit() : super(LogInitial());

  final List<Log> _maintenanceLogs = [
    Log(
      id: 1,
      atmId: 'ATM-001',
      location: 'Main Branch - Downtown',
      actionTaken: 'Replaced faulty cash dispenser unit.',
      status: LogStatus.completed,
      priority: LogPriority.high,
      createdAt: DateTime.parse('2024-10-20T14:30:00Z'),
      updatedAt: DateTime.parse('2024-10-20T14:30:00Z'),
    ),
    Log(
      id: 2,
      atmId: 'ATM-005',
      location: 'Shopping Mall - East',
      actionTaken: 'Refilled cash cassettes, performed routine cleaning.',
      status: LogStatus.in_progress,
      priority: LogPriority.medium,
      createdAt: DateTime.parse('2024-10-20T11:15:00Z'),
      updatedAt: DateTime.parse('2024-10-20T11:15:00Z'),
    ),
    Log(
      id: 3,
      atmId: 'ATM-012',
      location: 'Airport Terminal 2',
      actionTaken: 'Fixed jammed receipt printer, calibrated sensor.',
      status: LogStatus.completed,
      priority: LogPriority.low,
      createdAt: DateTime.parse('2024-10-19T09:00:00Z'),
      updatedAt: DateTime.parse('2024-10-19T09:00:00Z'),
    ),
    Log(
      id: 4,
      atmId: 'ATM-008',
      location: 'Central Market',
      actionTaken: 'Updated ATM software to latest version.',
      status: LogStatus.completed,
      priority: LogPriority.medium,
      createdAt: DateTime.parse('2024-10-18T16:45:00Z'),
      updatedAt: DateTime.parse('2024-10-18T16:45:00Z'),
    ),
    Log(
      id: 5,
      atmId: 'ATM-015',
      location: 'Train Station',
      actionTaken: 'Performed routine check and replaced worn parts.',
      status: LogStatus.completed,
      priority: LogPriority.low,
      createdAt: DateTime.parse('2024-10-18T10:20:00Z'),
      updatedAt: DateTime.parse('2024-10-18T10:20:00Z'),
    ),
  ];

  void fetchLogs() async {
    emit(LogLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    emit(LogLoaded(List.from(_maintenanceLogs)));
  }

  void addLog(Log log) async {
    emit(LogLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _maintenanceLogs.add(log);
    emit(LogLoaded(List.from(_maintenanceLogs)));
  }

  void updateLog(Log oldLog, Log newLog) async {
    emit(LogLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _maintenanceLogs.indexWhere((log) => log.id == oldLog.id);
    if (index != -1) {
      _maintenanceLogs[index] = newLog;
    }
    emit(LogLoaded(List.from(_maintenanceLogs)));
  }

  void deleteLog(Log log) async {
    emit(LogLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _maintenanceLogs.removeWhere((l) => l.id == log.id);
    emit(LogLoaded(List.from(_maintenanceLogs)));
  }
}
