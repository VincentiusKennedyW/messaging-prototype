// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:using_chat_api/data/chat_cache_service.dart';
import 'package:using_chat_api/model/message_model.dart';

typedef MessageHandler = void Function(Message message);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  int? _userId;
  final _cache = ChatCacheService();

  MessageHandler? onMessage;

  void init(int userId) {
    if (_socket != null && _socket!.connected) return;
    _userId = userId;

    _socket = io.io('http://172.27.4.120:8001', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket?.onConnect((_) {
      print('🌐 [Socket] Connected as user $_userId');
      _socket?.emit('subscribe', 'laravel_database_user.$_userId');
    });

    _socket?.onAny((event, data) {
      if (event.toString().contains(':message.sent')) {
        _handleMessage(data);
      }
    });

    _socket?.connect();
  }

  void _handleMessage(dynamic data) {
    try {
      final message = Message.fromJson(data['message']);
      print('📨 [Socket] Message received: ${message.message}');

      // Save to Hive cache
      _cache.addMessageIfNotExist(
          message.senderId, message.receiverId, message);

      // Forward to UI if any page is listening
      if (onMessage != null) onMessage!(message);
    } catch (e) {
      print('❌ Failed to handle socket message: $e');
    }
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.destroy();
  }
}
