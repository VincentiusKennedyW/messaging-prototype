// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:using_chat_api/data/auth_service.dart';
import 'package:using_chat_api/data/chat_cache_service.dart';
import 'package:using_chat_api/data/chat_service.dart';
import 'package:using_chat_api/model/message_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  final AuthService _authService;
  final ChatCacheService _cacheService = ChatCacheService();

  int? _senderId;

  ChatBloc(this._chatService, this._authService) : super(ChatInitial()) {
    final user = _authService.getCachedUser();
    _senderId = user?.id;

    on<InitChat>(_onInitChat);
    on<FetchMessages>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<NewMessageReceived>(_onNewMessageReceived);
  }

  Future<void> _onInitChat(InitChat event, Emitter<ChatState> emit) async {
    if (_senderId == null) {
      emit(ChatError('User not logged in'));
      return;
    }

    final receiverId = event.receiverId;
    final token = await _authService.loadToken();

    final cached = _cacheService.getMessages(_senderId!, receiverId);
    emit(ChatLoaded(cached));

    final lastSync = _cacheService.getLastSyncTime(_senderId!, receiverId);
    final now = DateTime.now();
    final lastCachedMessage = cached.isNotEmpty ? cached.last.createdAt : null;

    final shouldSync = event.force ||
        lastSync == null ||
        now.difference(lastSync).inMinutes >= 2 ||
        (event.lastMessageTime != null &&
            (lastCachedMessage == null ||
                event.lastMessageTime!.isAfter(lastCachedMessage)));

    if (!shouldSync) {
      print('🛑 Skip sync, considered up-to-date.');
      return;
    }

    try {
      print('🔄 Syncing...');
      final serverMessages = await _chatService.getMessages(token!, receiverId);

      final newMessages = serverMessages
          .where((m) => !cached.any((c) => c.id == m.id))
          .toList();

      if (newMessages.isNotEmpty) {
        final updated = [...cached, ...newMessages];
        updated.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        emit(ChatLoaded(updated));
        await _cacheService.saveMessages(_senderId!, receiverId, updated);
      }

      await _cacheService.updateLastSyncTime(_senderId!, receiverId);
    } catch (e) {
      print('❌ Sync error: $e');
    }
  }

  Future<void> _onFetchMessages(
      FetchMessages event, Emitter<ChatState> emit) async {
    if (_senderId == null) {
      emit(ChatError('User not logged in'));
      return;
    }

    final token = await _authService.loadToken();
    final receiverId = event.receiverId;

    final cachedMessages = _cacheService.getMessages(_senderId!, receiverId);

    if (cachedMessages.isNotEmpty) {
      emit(ChatLoaded(cachedMessages));
    } else {
      try {
        print('📡 Fetching from server for receiverId = $receiverId');

        final messages = await _chatService.getMessages(token!, receiverId);
        emit(ChatLoaded(messages));
        await _cacheService.saveMessages(_senderId!, receiverId, messages);
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    final token = await _authService.loadToken();
    try {
      await _chatService.sendMessage(token!, event.message, event.receiverId);
      // Real-time update akan ditangani oleh socket (NewMessageReceived)
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> addMessageFromOtherUser(Message message) async {
    final currentUserId = _authService.getCachedUser()?.id;
    if (currentUserId != null) {
      final chatUserId = message.senderId == currentUserId
          ? message.receiverId
          : message.senderId;
      await _cacheService.addMessageIfNotExist(
          currentUserId, chatUserId, message);
    }
  }

  Future<void> _onNewMessageReceived(
      NewMessageReceived event, Emitter<ChatState> emit) async {
    if (_senderId == null) return;

    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      final alreadyExist =
          currentState.messages.any((msg) => msg.id == event.message.id);

      if (!alreadyExist) {
        final updatedMessages = List<Message>.from(currentState.messages)
          ..add(event.message);

        emit(ChatLoaded(updatedMessages));

        // await _cacheService.addMessageIfNotExist(
        //     _senderId!, event.message.receiverId, event.message);
        await addMessageFromOtherUser(event.message);
      } else {
        print('⚠️ Duplicate message ID ${event.message.id} ignored');
      }
    }
  }
}
