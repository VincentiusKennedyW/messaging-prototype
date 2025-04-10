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

  ChatBloc(this._chatService, this._authService) : super(ChatLoading()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<NewMessageReceived>(_onNewMessageReceived);
  }

  Future<void> _onFetchMessages(
      FetchMessages event, Emitter<ChatState> emit) async {
    final token = await _authService.loadToken();

    final cachedMessages = _cacheService.getMessages(event.receiverId);

    if (cachedMessages.isNotEmpty) {
      emit(ChatLoaded(cachedMessages));
    } else {
      try {
        final messages =
            await _chatService.getMessages(token!, event.receiverId);
        emit(ChatLoaded(messages));
        await _cacheService.saveMessages(event.receiverId, messages);
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
      // Tidak menambahkan pesan ke state di sini
      // Pesan akan ditambahkan melalui socket saat diterima kembali
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onNewMessageReceived(
      NewMessageReceived event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      // Cek apakah pesan sudah ada berdasarkan ID
      if (!currentState.messages.any((msg) => msg.id == event.message.id)) {
        final updatedMessages = List<Message>.from(currentState.messages)
          ..add(event.message);
        emit(ChatLoaded(updatedMessages));

        await _cacheService.addMessages(
            event.message.receiverId, event.message);
      }
    }
  }
}
