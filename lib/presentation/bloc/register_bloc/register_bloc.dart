import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:using_chat_api/data/auth_service.dart';

part 'register_bloc.freezed.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService _authService;

  RegisterBloc(this._authService) : super(const _RegisterInitial()) {
    on<_Register>((event, emit) async {
      emit(const RegisterState.registerLoading());
      try {
        await _authService.register(
          event.username,
          event.email,
          event.password,
        );
        emit(const RegisterState.registered());
      } catch (error) {
        emit(RegisterState.registerError(error.toString()));
      }
    });
  }
}
