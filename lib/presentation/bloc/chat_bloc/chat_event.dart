part of 'chat_bloc.dart';

abstract class ChatEvent {}

class FetchMessages extends ChatEvent {
  final int receiverId;

  FetchMessages(this.receiverId);
}

class SendMessageEvent extends ChatEvent {
  final String message;
  final int receiverId;

  SendMessageEvent(this.message, this.receiverId);
}

class NewMessageReceived extends ChatEvent {
  final Message message;

  NewMessageReceived(this.message);
}
