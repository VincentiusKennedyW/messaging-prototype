part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.login(
      {required String username, required String password}) = _Login;
  const factory LoginEvent.loggedOut() = _LoggedOut;
  const factory LoginEvent.isLoggedIn() = _IsLoggedIn;
}
