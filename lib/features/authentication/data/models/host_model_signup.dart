
import '../../domain/entities/user_entities_signup.dart';

class HostModelSignup {
  final String role;
  final String fullName;
  final String userName;
  final String email;
  final String password;
  
  HostModelSignup({
    required this.userName,
    required this.role,
    required this.fullName,
    required this.email,
    required this.password,
  });

  factory HostModelSignup.fromJson(Map<String, dynamic> json) {
    // For OTP response, return input data
    if (json.containsKey('message')) {
      return HostModelSignup(
        userName: json['username'] ?? '',
        fullName: json['fullname'] ?? '',
        role: json['role'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
      );
    }
    return HostModelSignup(
      userName: json['username'],
      fullName: json['fullname'],
      role: json['role'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': userName,
      'fullname': fullName,
      'email': email,
      'role': role,
      'password': password,
    };
  }

  HostEntitiesSignup toEntity() {
    return HostEntitiesSignup(
      username: userName,
      fullName: fullName,
      password: password,
      role: role,
      email: email,
    );
  }
}
