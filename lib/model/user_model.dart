import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? phoneCountry;
  final String email;
  final String role;
  final String? driverLicense;
  final DateTime? birthDate;
  final bool isTempPassword;
  final String? imageProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.phoneCountry,
    required this.email,
    required this.role,
    this.driverLicense,
    this.birthDate,
    this.isTempPassword = false,
    this.imageProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      phoneCountry: json['phone_country'],
      email: json['email'] as String,
      role: json['role'] as String,
      driverLicense: json['driver_license'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      isTempPassword: json['is_temp_password'] ?? false,
      imageProfile: json['image_profile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'driver_license': driverLicense,
      'birth_date': birthDate?.toIso8601String(),
      'is_temp_password': isTempPassword,
      'image_profile': imageProfile,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => 'UserModel(id: \$id, name: \$name, email: \$email)';
}
