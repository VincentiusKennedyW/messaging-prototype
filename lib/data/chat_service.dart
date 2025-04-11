import 'dart:async';
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;
import 'package:using_chat_api/model/contact_model.dart';
import 'package:using_chat_api/model/message_model.dart';

class ChatService {
  final void Function(Message message)? onMessageReceived;

  ChatService({this.onMessageReceived});

  io.Socket? socket;
  final String baseUrl = "http://172.27.4.120:8000/api";

  // void connect(int receiverId, int senderId) {
  //   socket = io.io('http://172.27.4.120:8001', <String, dynamic>{
  //     'transports': ['websocket'],
  //     'autoConnect': false,
  //   });

  //   socket?.onConnect((_) {
  //     print('Connected');
  //     socket?.emit('subscribe',
  //         'laravel_database_private-chat-channel.$receiverId.$senderId');
  //     socket?.emit('subscribe',
  //         'laravel_database_private-chat-channel.$senderId.$receiverId');
  //   });

  //   socket?.on(
  //       'laravel_database_private-chat-channel.$receiverId.$senderId:message.sent',
  //       (data) {
  //     print('Pesan diterima dari receiver ke sender: $data');
  //     _handleIncomingMessage(data);
  //   });

  //   socket?.on(
  //       'laravel_database_private-chat-channel.$senderId.$receiverId:message.sent',
  //       (data) {
  //     print('Pesan diterima dari sender ke receiver: $data');
  //     _handleIncomingMessage(data);
  //   });

  //   socket?.connect();
  // }

  void _handleIncomingMessage(data) {
    try {
      final message = Message.fromJson(data['message'] ?? {});
      if (onMessageReceived != null) {
        onMessageReceived!(message);
      }
    } catch (e) {
      print('Error dalam parsing pesan: $e');
    }
  }

  void disconnect() {
    socket?.disconnect();
  }

  Future<Message> sendMessage(
      String token, String message, int receiverId) async {
    print('📡 ChatService.sendMessage called! receiverId = $receiverId');
    final Uri url = Uri.parse("$baseUrl/messages");

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode(<String, dynamic>{
      'receiver_id': receiverId,
      'message': message,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          final message = Message.fromJson(responseData['message']);
          return message;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception("Failed to send message");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Message>> getMessages(String token, int receiverId) async {
    print('📡 ChatService.getMessages called! receiverId = $receiverId');
    print('📡 ChatService.getMessages (SYNC) for $receiverId');

    final url = 'http://172.27.4.120:8000/api/messages/$receiverId';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Stream<List<ContactModel>> getContactsStream(String token) async* {
    print('📡 ChatService.getContactStream called!');

    final Uri url = Uri.parse("$baseUrl/contacts");

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final StreamController<List<ContactModel>> streamController =
        StreamController();

    Future<void> fetchData() async {
      try {
        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final List<dynamic> responseData = json.decode(response.body);
          final List<ContactModel> contacts = responseData
              .map((contact) => ContactModel.fromJson(contact))
              .toList();

          streamController.add(contacts);
        } else {
          // Handle the error here
          streamController.addError('Failed to load contacts');
        }
      } catch (e) {
        streamController.addError(e.toString());
      }
    }

    await fetchData();
    yield* streamController.stream;
  }
}
