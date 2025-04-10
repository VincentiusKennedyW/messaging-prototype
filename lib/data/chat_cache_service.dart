import 'package:hive/hive.dart';
import 'package:using_chat_api/model/message_model.dart';

class ChatCacheService {
  final Box<List> _chatBox = Hive.box<List>('chat_messages');

  List<Message> getMessages(int receiverId) {
    final cached = _chatBox.get(receiverId.toString());
    return cached?.cast<Message>() ?? [];
  }

  Future<void> saveMessages(int receiverId, List<Message> messages) async {
    await _chatBox.put(receiverId.toString(), messages);
  }

  Future<void> addMessages(int receiverId, Message message) async {
    final messages = getMessages(receiverId);
    final updatedMessages = [...messages, message];
    await saveMessages(receiverId, updatedMessages);
  }

  Future<void> clearMessages(int receiverId) async {
    await _chatBox.delete(receiverId.toString());
  }
}
