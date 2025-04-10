import 'package:bloc/bloc.dart';
import 'package:using_chat_api/data/auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;

  LoginBloc(this._authService) : super(NotLoggedIn()) {
    on<Login>((event, emit) async {
      emit(LoginLoading());
      try {
        final token = await _authService.login(
          event.username,
          event.password,
        );
        await _authService.persistToken(token);
        emit(LoggedIn(token));
      } catch (e) {
        emit(LoginError('Failed to login: $e'));
      }
    });

    on<IsLoggedIn>((event, emit) async {
      emit(LoginLoading());
      try {
        final token = await _authService.loadToken();
        if (token != null) {
          emit(LoggedIn(token));
          print('Logged in with token: $token');
        } else {
          emit(NotLoggedIn());
        }
      } catch (e) {
        emit(LoginError('Failed to check login status: $e'));
      }
    });

    on<LoggedOut>((event, emit) async {
      try {
        final token = await _authService.loadToken();
        await _authService.logout(token!);
        await _authService.deleteToken();
        print('Logged out');
        emit(NotLoggedIn());
      } catch (e) {
        emit(LoginError('Failed to logout: $e'));
      }
    });
  }
}
