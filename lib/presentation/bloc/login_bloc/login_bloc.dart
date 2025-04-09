import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:using_chat_api/data/auth_service.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;

  LoginBloc(this._authService) : super(const _NotLoggedIn()) {
    on<_Login>((event, emit) async {
      emit(const LoginState.loginLoading());
      try {
        final token = await _authService.login(
          event.username,
          event.password,
        );
        await _authService.persistToken(token);
        emit(LoginState.loggedIn(token));
      } catch (e) {
        emit(LoginState.loginError('Failed to login: $e'));
      }
    });

    on<_IsLoggedIn>((event, emit) async {
      emit(const LoginState.loginLoading());
      try {
        final token = await _authService.loadToken();
        if (token != null) {
          emit(LoginState.loggedIn(token));
          print('Logged in with token: $token');
        } else {
          emit(const LoginState.notLoggedIn());
        }
      } catch (e) {
        emit(LoginState.loginError('Failed to check login status: $e'));
      }
    });

    on<_LoggedOut>((event, emit) async {
      try {
        final token = await _authService.loadToken();
        await _authService.logout(token!);
        await _authService.deleteToken();
        print('Logged out');
        emit(const LoginState.notLoggedIn());
      } catch (e) {
        emit(LoginState.loginError('Failed to logout: $e'));
      }
    });
  }
}
