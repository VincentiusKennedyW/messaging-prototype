part of 'register_bloc.dart';

abstract class RegisterEvent {}

class Register extends RegisterEvent {
  final String username;
  final String email;
  final String password;

  Register({
    required this.username,
    required this.email,
    required this.password,
  });
}
