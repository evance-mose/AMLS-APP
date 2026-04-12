part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final int totalLogs;
  final int totalIssues;
  final int completedLogs;
  final int pendingLogs;
  final int inProgressLogs;
  final int openIssues;
  final int acknowledgedIssues;
  final int criticalIssues;
  final double resolutionRate;
  final double avgResolutionTime;
  final List<Log> recentLogs;
  final List<Issue> recentIssues;
  final MonthlyReport? monthlyReport;

  /// Counts of new issues per calendar day for the last 7 days (oldest → newest).
  final List<double> issuesPerDayLast7;

  /// Counts of new logs per calendar day for the last 7 days (oldest → newest).
  final List<double> logsPerDayLast7;

  HomeLoaded({
    required this.totalLogs,
    required this.totalIssues,
    required this.completedLogs,
    required this.pendingLogs,
    required this.inProgressLogs,
    required this.openIssues,
    required this.acknowledgedIssues,
    required this.criticalIssues,
    required this.resolutionRate,
    required this.avgResolutionTime,
    required this.recentLogs,
    required this.recentIssues,
    required this.issuesPerDayLast7,
    required this.logsPerDayLast7,
    this.monthlyReport,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
