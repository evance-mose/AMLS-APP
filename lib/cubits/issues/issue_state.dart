part of 'issue_cubit.dart';

@immutable
abstract class IssueState {}

class IssueInitial extends IssueState {}

class IssueLoading extends IssueState {}

class IssueLoaded extends IssueState {
  final List<Map<String, dynamic>> issues;

  IssueLoaded(this.issues);
}

class IssueError extends IssueState {
  final String message;

  IssueError(this.message);
}
