import 'package:get_it/get_it.dart';
import 'package:using_chat_api/data/auth_service.dart';
import 'package:using_chat_api/data/chat_cache_service.dart';
import 'package:using_chat_api/data/chat_service.dart';
import 'package:using_chat_api/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:using_chat_api/presentation/bloc/contact_bloc/contact_bloc.dart';
import 'package:using_chat_api/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:using_chat_api/presentation/bloc/register_bloc/register_bloc.dart';
import 'package:using_chat_api/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:using_chat_api/presentation/screen/chat_page.dart';
import 'package:using_chat_api/presentation/screen/contact_page.dart';

final locator = GetIt.instance;

void init() {
  locator.registerFactory(() => LoginBloc(locator()));
  locator.registerFactory(() => RegisterBloc(locator()));
  locator.registerFactory(() => UserBloc(locator()));
  locator.registerFactory(() => ChatBloc(locator(), locator()));
  locator.registerFactory(() => ContactBloc(locator(), locator()));
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<ChatService>(() => ChatService());
  locator.registerLazySingleton(() => ChatCacheService());

  locator.registerFactory(() => const ChatPage(receiverId: 0));
  locator.registerFactory(() => ContactPage());
}
