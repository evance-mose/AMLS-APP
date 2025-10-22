import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/models/log_model.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/models/issue_model.dart';

part 'log_state.dart';

class LogCubit extends Cubit<LogState> {
  LogCubit() : super(LogInitial());

  final List<Log> _maintenanceLogs = [
    Log(
      id: 1,
      userId: 1,
      issueId: 1,
      actionTaken: 'Replaced faulty cash dispenser unit.',
      status: LogStatus.completed,
      priority: LogPriority.high,
      createdAt: DateTime.parse('2024-10-20T14:30:00Z'),
      updatedAt: DateTime.parse('2024-10-20T14:30:00Z'),
      user: User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        emailVerifiedAt: DateTime.parse('2024-01-01T00:00:00Z'),
        password: 'password',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
        role: UserRole.technician,
        status: UserStatus.active,
      ),
      issue: Issue(
        id: 1,
        userId: 1,
        assignedTo: 1,
        location: 'Main Branch - Downtown',
        atmId: 'ATM-001',
        category: IssueCategory.dispenser_errors,
        description: 'Cash dispenser not working',
        status: IssueStatus.resolved,
        priority: IssuePriority.high,
        reportedDate: DateTime.parse('2024-10-20T10:00:00Z'),
        createdAt: DateTime.parse('2024-10-20T10:00:00Z'),
        updatedAt: DateTime.parse('2024-10-20T14:30:00Z'),
      ),
    ),
    Log(
      id: 2,
      userId: 2,
      issueId: 2,
      actionTaken: 'Refilled cash cassettes, performed routine cleaning.',
      status: LogStatus.in_progress,
      priority: LogPriority.medium,
      createdAt: DateTime.parse('2024-10-20T11:15:00Z'),
      updatedAt: DateTime.parse('2024-10-20T11:15:00Z'),
      user: User(
        id: 2,
        name: 'Jane Smith',
        email: 'jane@example.com',
        emailVerifiedAt: DateTime.parse('2024-01-01T00:00:00Z'),
        password: 'password',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
        role: UserRole.technician,
        status: UserStatus.active,
      ),
      issue: Issue(
        id: 2,
        userId: 1,
        assignedTo: 2,
        location: 'Shopping Mall - East',
        atmId: 'ATM-005',
        category: IssueCategory.card_reader_errors,
        description: 'Card reader malfunction',
        status: IssueStatus.assigned,
        priority: IssuePriority.medium,
        reportedDate: DateTime.parse('2024-10-20T09:00:00Z'),
        createdAt: DateTime.parse('2024-10-20T09:00:00Z'),
        updatedAt: DateTime.parse('2024-10-20T11:15:00Z'),
      ),
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
