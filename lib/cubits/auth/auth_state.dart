part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final User? user;

  AuthAuthenticated({
    required this.token,
    this.user,
  });
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
