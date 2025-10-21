part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;

  AuthAuthenticated(this.username);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
