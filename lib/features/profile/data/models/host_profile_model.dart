
import '../../domain/entities/host_profile_entity.dart';

class HostProfileModel {
  final int id;
  final String username;
  final String? profileImage;
  final String fullName;
  final String? phoneNumber;
  final String email;
  final String role;
  final String? password;

  HostProfileModel({
    required this.id,
    required this.username,
    this.profileImage,
    required this.fullName,
    this.phoneNumber,
    this.password,
    required this.email,
    required this.role,
  });

  factory HostProfileModel.fromJson(Map<String, dynamic> json) {
    return HostProfileModel(
      id: int.parse(json['id'].toString()),
      username: json['username'] ?? '',
      profileImage: json['profile_picture'],
      fullName: json['fullname'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phone_number'],
      password: null,
    );
  }

  Map<String, dynamic> toJson({bool onlyProfileImage = false}) {
    if (onlyProfileImage) {
      return {
        'profile_publicId': profileImage,
      };
    } else {
      return {
        'id': id,
        'username': username,
        'fullname': fullName,
        'email': email,
        'phone_number': phoneNumber,
      };
    }
  }

  HostProfileEntity toEntity() {
    return HostProfileEntity(
      id: id.toString(),
      profileImage: profileImage,
      username: username,
      fullName: fullName,
      password: password,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
    );
  }
}
