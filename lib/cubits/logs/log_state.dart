part of 'log_cubit.dart';

@immutable
abstract class LogState {}

class LogInitial extends LogState {}

class LogLoading extends LogState {}

class LogLoaded extends LogState {
  final List<Log> logs;

  LogLoaded(this.logs);
}

class LogError extends LogState {
  final String message;

  LogError(this.message);
}
