part of 'register_bloc.dart';

@freezed
class RegisterEvent with _$RegisterEvent {
  const factory RegisterEvent.register({
    required String username,
    required String email,
    required String password,
  }) = _Register;
}
