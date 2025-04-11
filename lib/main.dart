import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:using_chat_api/model/message_model.dart';
import 'package:using_chat_api/model/user_model.dart';
import 'package:using_chat_api/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:using_chat_api/presentation/bloc/contact_bloc/contact_bloc.dart';
import 'package:using_chat_api/utils/injection.dart' as di;
import 'package:using_chat_api/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:using_chat_api/presentation/bloc/register_bloc/register_bloc.dart';
import 'package:using_chat_api/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:using_chat_api/utils/routes.dart';
import 'package:using_chat_api/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox<List>('chat_messages');

  await Hive.openBox('chat_meta');

  Hive.registerAdapter(UserDataAdapter());
  await Hive.openBox<UserData>('user_box');

  runApp(MainApp());
  di.init();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => di.locator<LoginBloc>()..add(IsLoggedIn())),
        BlocProvider(create: (context) => di.locator<RegisterBloc>()),
        BlocProvider(create: (context) => di.locator<UserBloc>()),
        BlocProvider(create: (context) => di.locator<ChatBloc>()),
        BlocProvider(create: (context) => di.locator<ContactBloc>()),
      ],
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoggedIn) {
            router.goNamed('contact');
          } else if (state is NotLoggedIn) {
            router.goNamed('login');
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Chat',
          theme: ThemeData(
            textTheme: myTextTheme,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: primaryColor,
                secondary: secondaryColor,
                onPrimary: thirdColor,
                surface: fourthColor),
            appBarTheme: const AppBarTheme(
              backgroundColor: thirdColor,
              elevation: 0,
              iconTheme: IconThemeData(color: fourthColor),
              titleTextStyle: TextStyle(color: fourthColor, fontSize: 20),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: thirdColor,
                foregroundColor: fourthColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: thirdColor),
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
