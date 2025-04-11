import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:using_chat_api/model/user_model.dart';

class AuthService {
  static String baseUrl = "http://172.27.4.120:8000/api";

  var loginUrl = '$baseUrl/login';
  var registerUrl = '$baseUrl/register';
  var logoutUrl = '$baseUrl/logout';
  var meUrl = '$baseUrl/me';

  Future<String> login(String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: jsonEncode({
          'name': name,
          'password': password,
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        return token;
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'];
        throw Exception(errorMessage ?? "Failed to login");
      }
    } catch (e) {
      throw Exception("Failed to login: $e");
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        return;
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'];
        throw Exception(errorMessage ?? "Failed to register");
      }
    } catch (e) {
      throw Exception("Failed to register: $e");
    }
  }

  Future<String?> loadToken() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getString('token');
  }

  Future<void> persistToken(String token) async {
    final storage = await SharedPreferences.getInstance();
    storage.setString('token', token);
  }

  Future<void> persistUser(UserData user) async {
    final box = Hive.box<UserData>('user_box');
    await box.put('current_user', user);
  }

  UserData? getCachedUser() {
    final box = Hive.box<UserData>('user_box');
    return box.get('current_user');
  }

  Future<void> clearUser() async {
    final box = Hive.box<UserData>('user_box');
    await box.delete('current_user');
  }

  Future<void> deleteToken() async {
    final storage = await SharedPreferences.getInstance();
    storage.remove('token');
  }

  Future<UserModel> getUserData(String token) async {
    final response = await http.get(
      Uri.parse(meUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final user = UserData.fromJson(responseData['data']);
      return UserModel(
        error: responseData['error'],
        message: responseData['message'],
        data: user,
      );
    } else {
      throw Exception("Failed to get user data");
    }
  }

  // Future<int?> getSenderId() async {
  //   final token = await loadToken();
  //   if (token != null) {
  //     final userModel = await getUserData(token);
  //     return userModel.data.id;
  //   }
  //   return null;
  // }

  Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(logoutUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await deleteToken();
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'];
        throw Exception(errorMessage ?? "Failed to logout");
      }
    } catch (e) {
      throw Exception("Failed to logout: $e");
    }
  }
}
