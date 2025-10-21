part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final int totalLogs;
  final int activeIssues;
  final int inProgressLogs;
  final int criticalIssues;

  HomeLoaded({
    required this.totalLogs,
    required this.activeIssues,
    required this.inProgressLogs,
    required this.criticalIssues,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
