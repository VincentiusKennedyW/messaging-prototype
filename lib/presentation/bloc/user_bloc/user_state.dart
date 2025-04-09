part of 'user_bloc.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.userInitial() = _UserInitial;
  const factory UserState.userLoading() = _UserLoading;
  const factory UserState.userLoaded(UserData user) = _UserLoaded;
  const factory UserState.userError(String message) = _UserError;
}
