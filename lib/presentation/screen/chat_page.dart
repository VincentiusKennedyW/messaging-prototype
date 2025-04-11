import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:using_chat_api/data/auth_service.dart';
import 'package:using_chat_api/data/chat_service.dart';
import 'package:using_chat_api/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:using_chat_api/utils/injection.dart' as di;

class ChatPage extends StatefulWidget {
  final int receiverId;

  const ChatPage({
    required this.receiverId,
    super.key,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatBloc _chatBloc;
  late ChatService _chatService;
  late AuthService _authService;
  int? senderId;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _chatService = ChatService(
      onMessageReceived: (message) {
        _chatBloc.add(NewMessageReceived(message));
        _scrollToBottom();
      },
    );
    print('👤 ChatPage receiverId = ${widget.receiverId}');

    _chatBloc = di.locator<ChatBloc>();
    if (_chatBloc.state is! ChatLoaded) {
      _chatBloc.add(InitChat(widget.receiverId));
    }
    // ChatCacheService().debugPrintAll();

    _getSenderId();
  }

  Future<void> _getSenderId() async {
    final user = _authService.getCachedUser(); // ✅ ambil dari Hive
    if (user != null) {
      setState(() {
        senderId = user.id;
      });
      _chatService.connect(widget.receiverId, senderId!);
    } else {
      print('User not found in cache');
    }
  }

  void _scrollToBottom({bool isInitialLoad = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (isInitialLoad) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatService.disconnect();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatBloc
          .add(SendMessageEvent(_messageController.text, widget.receiverId));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: senderId == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    bloc: _chatBloc,
                    builder: (context, state) {
                      if (state is ChatLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ChatLoaded) {
                        _scrollToBottom(isInitialLoad: true);

                        if (state.messages.isEmpty) {
                          return const Center(child: Text('Tidak ada pesan'));
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = message.senderId == senderId;
                            final messageTime = DateFormat('HH:mm')
                                .format(message.createdAt); // Format time

                            return Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Colors.blue
                                              : Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          message.message,
                                          style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black87),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 16, bottom: 4, left: 16),
                                        child: Text(
                                          messageTime,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (state is ChatError) {
                        return Center(
                          child: Text('Error: ${state.message}'),
                        );
                      } else {
                        return const Center(child: Text('Tidak ada pesan'));
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: "Type a message",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
