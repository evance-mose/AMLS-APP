import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (username == 'test' && password == 'password') {
      emit(AuthAuthenticated(username));
    } else {
      emit(AuthError('Invalid credentials'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthInitial());
  }
}
