import 'package:hive/hive.dart';
import 'package:using_chat_api/model/message_model.dart';

class ChatCacheService {
  final Box<List> _chatBox = Hive.box<List>('chat_messages');
  final Box _metaBox = Hive.box('chat_meta');

  String _getChatKey(int userId1, int userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  List<Message> getMessages(int userId1, int userId2) {
    final key = _getChatKey(userId1, userId2);
    final cached = _chatBox.get(key);
    return cached?.cast<Message>() ?? [];
  }

  Future<void> saveMessages(
      int userId1, int userId2, List<Message> messages) async {
    final key = _getChatKey(userId1, userId2);
    await _chatBox.put(key, messages);
  }

  Future<void> addMessageIfNotExist(
      int userId1, int userId2, Message message) async {
    final messages = getMessages(userId1, userId2);
    final alreadyExist = messages.any((m) => m.id == message.id);

    if (!alreadyExist) {
      final updatedMessages = [...messages, message];
      updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      await saveMessages(userId1, userId2, updatedMessages);
    } else {
      print('⚠️ Message ID ${message.id} already exists in cache.');
    }
  }

  DateTime? getLastSyncTime(int userId1, int userId2) {
    final key = _getChatKey(userId1, userId2);
    final ts = _metaBox.get('last_sync_$key');
    return ts != null ? DateTime.tryParse(ts) : null;
  }

  Future<void> updateLastSyncTime(int userId1, int userId2) async {
    final key = _getChatKey(userId1, userId2);
    await _metaBox.put('last_sync_$key', DateTime.now().toIso8601String());
  }

  Future<void> clearMessages(int userId1, int userId2) async {
    final key = _getChatKey(userId1, userId2);
    await _chatBox.delete(key);
    await _metaBox.delete('last_sync_$key');
  }

  void debugPrintAll() {
    print('📦 Hive Cache (chat_messages):');
    for (var key in _chatBox.keys) {
      final messages = _chatBox.get(key)?.cast<Message>() ?? [];
      print('🔑 ChatKey: $key (${messages.length} messages)');
      for (var msg in messages) {
        print(
            '➡️ [${msg.createdAt}] ${msg.senderId} -> ${msg.receiverId}: ${msg.message}');
      }
    }
  }
}
