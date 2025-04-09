import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:using_chat_api/data/auth_service.dart';
import 'package:using_chat_api/model/user_model.dart';

part 'user_bloc.freezed.dart';
part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthService _authService;

  UserBloc(this._authService) : super(const _UserInitial()) {
    on<_GetUserData>((event, emit) async {
      try {
        final token = await _authService.loadToken();
        if (token != null) {
          final userResponse = await _authService.getUserData(token);
          if (!userResponse.error) {
            emit(UserState.userLoaded(userResponse.data));
          } else {
            emit(UserState.userError(userResponse.message));
          }
        } else {
          emit(const UserState.userError("Token not found"));
        }
      } catch (e) {
        emit(const UserState.userError("Failed to fetch user data"));
      }
    });
  }
}
