part of 'issue_cubit.dart';

@immutable
abstract class IssueState {}

class IssueInitial extends IssueState {}

class IssueLoading extends IssueState {}

class IssueLoaded extends IssueState {
  final List<Issue> issues;
  final bool fromCache;

  IssueLoaded(this.issues, {this.fromCache = false});
}

class IssueError extends IssueState {
  final String message;

  IssueError(this.message);
}
