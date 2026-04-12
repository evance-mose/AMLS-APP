part of 'log_cubit.dart';

@immutable
abstract class LogState {}

class LogInitial extends LogState {}

class LogLoading extends LogState {}

class LogLoaded extends LogState {
  final List<Log> logs;
  final bool fromCache;

  LogLoaded(this.logs, {this.fromCache = false});
}

class LogError extends LogState {
  final String message;

  LogError(this.message);
}
