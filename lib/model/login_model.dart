class LoginModel {
  bool error;
  String message;
  String token;

  LoginModel({
    required this.error,
    required this.message,
    required this.token,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      error: json['error'],
      message: json['message'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'token': token,
    };
  }
}
