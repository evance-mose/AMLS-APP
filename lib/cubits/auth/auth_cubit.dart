import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/services/auth_service.dart';
import 'package:amls/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    _checkAuthStatus();
  }

  // Check if user is already authenticated on app start
  Future<void> _checkAuthStatus() async {
    try {
      final isAuthenticated = await AuthService.isAuthenticated();
      if (isAuthenticated) {
        final token = await AuthService.getToken();
        final user = await AuthService.getUser();
        if (token != null) {
          emit(AuthAuthenticated(token: token, user: user));
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await AuthService.login(email, password);
      emit(AuthAuthenticated(
        token: result['token'],
        user: result['user'],
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await AuthService.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
