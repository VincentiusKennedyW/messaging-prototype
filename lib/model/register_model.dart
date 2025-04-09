class RegisterModel {
  bool error;
  String message;
  List<RegisterData> data;

  RegisterModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      error: json['error'],
      message: json['message'],
      data: List<RegisterData>.from(
          json['data'].map((x) => RegisterData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class RegisterData {
  String id;
  String name;
  String email;

  RegisterData({
    required this.id,
    required this.name,
    required this.email,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
