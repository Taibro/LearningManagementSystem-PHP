import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repositories/auth_repository.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/fcm_service.dart';
import '../../core/network/stomp_chat_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.mobileLogin(
        loginCode: event.loginCode,
        password: event.password,
        userType: event.userType,
        schoolCode: event.schoolCode,
      );

      if (user.token != null) {
        await SecureStorage.saveToken(user.token!);
        if (user.role != null) {
          await SecureStorage.saveRole(user.role!);
        }
        // Initialize FCM and send token to server after saving auth token
        await FcmService.init();
        
        // Initialize Global STOMP Connection for real-time chat notifications
        await StompChatService().initGlobalConnection();
      }

      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    StompChatService().disconnect();
    await SecureStorage.deleteToken();
    emit(AuthInitial());
  }
}
