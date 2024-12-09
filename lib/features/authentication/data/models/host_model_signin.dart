import '../../domain/entities/user_model_signin.dart';

class HostModelSignIn {
  final int id;
  final String accessToken;
  final String refreshToken;
  final String username;
  final String email;
  final String role;

  HostModelSignIn({
    required this.accessToken,
    required this.refreshToken,
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory HostModelSignIn.fromJson(Map<String, dynamic> json) {
    return HostModelSignIn(
      id: json['id'] ?? 0,
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  HostEntitySignIn toEntity() {
    return HostEntitySignIn(
      id: id,
      accessToken: accessToken,
      refreshToken: refreshToken,
      username: username,
      email: email,
      role: role,
    );
  }
}
