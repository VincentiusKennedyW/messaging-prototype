part of 'login_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class NotLoggedIn extends LoginState {}

class LoginLoading extends LoginState {}

class LoggedIn extends LoginState {
  final String token;

  LoggedIn(this.token);
}

class LoginError extends LoginState {
  final String message;

  LoginError(this.message);
}
