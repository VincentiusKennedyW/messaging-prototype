import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:using_chat_api/presentation/screen/auth_screen/login_screen.dart';
import 'package:using_chat_api/presentation/screen/auth_screen/register_screen.dart';
import 'package:using_chat_api/presentation/screen/chat_page.dart';
import 'package:using_chat_api/presentation/screen/contact_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/contact',
  routes: [
    GoRoute(
      name: 'contact',
      path: '/contact',
      builder: (context, state) {
        return ContactPage();
      },
      routes: [
        GoRoute(
          name: 'list',
          path: 'list/:receiverId',
          builder: (context, state) {
            final receiverId = int.parse(state.pathParameters['receiverId']!);
            return ChatPage(receiverId: receiverId);
          },
        ),
      ],
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
