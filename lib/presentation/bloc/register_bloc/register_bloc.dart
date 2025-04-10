import 'package:bloc/bloc.dart';
import 'package:using_chat_api/data/auth_service.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService _authService;

  RegisterBloc(this._authService) : super(RegisterInitial()) {
    on<Register>((event, emit) async {
      emit(RegisterLoading());
      try {
        await _authService.register(
          event.username,
          event.email,
          event.password,
        );
        emit(Registered());
      } catch (error) {
        emit(RegisterError(error.toString()));
      }
    });
  }
}
