import 'package:bloc/bloc.dart';
import 'package:using_chat_api/data/auth_service.dart';
import 'package:using_chat_api/model/user_model.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthService _authService;

  UserBloc(this._authService) : super(UserInitial()) {
    on<GetUserData>((event, emit) async {
      try {
        final token = await _authService.loadToken();
        if (token != null) {
          final userResponse = await _authService.getUserData(token);
          if (!userResponse.error) {
            emit(UserLoaded(userResponse.data));
          } else {
            emit(UserError(userResponse.message));
          }
        } else {
          emit(UserError("Token not found!"));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
