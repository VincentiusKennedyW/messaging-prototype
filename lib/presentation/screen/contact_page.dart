import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:using_chat_api/data/auth_service.dart';
import 'package:using_chat_api/data/chat_service.dart';
import 'package:using_chat_api/presentation/bloc/contact_bloc/contact_bloc.dart';
import 'package:using_chat_api/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:using_chat_api/utils/injection.dart';

class ContactPage extends StatelessWidget {
  final AuthService authService = locator<AuthService>();
  final ChatService chatService = locator<ChatService>();

  ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ContactBloc(authService, chatService)..add(FetchContacts()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contact Page'),
          actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<LoginBloc>().add(LoggedOut());
                              context.pop();
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                })
          ],
        ),
        body: BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContactLoaded) {
              return ListView.builder(
                itemCount: state.contacts.length,
                itemBuilder: (context, index) {
                  final contact = state.contacts[index];
                  return ListTile(
                    title: Text(contact.name),
                    subtitle: Text('Email: ${contact.email}'),
                    onTap: () {
                      context.goNamed(
                        'list',
                        pathParameters: {'receiverId': contact.id.toString()},
                      );
                    },
                  );
                },
              );
            } else if (state is ContactError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('No Data Available'));
            }
          },
        ),
      ),
    );
  }
}
