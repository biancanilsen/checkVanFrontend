import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/user_session.dart';
import '../network/endpoints.dart';

class UserService {
  static Future<bool> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? password,
    String? license,
    DateTime? birthDate,
  }) async {
    final token = await UserSession.getToken();

    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    if (license != null) body['driver_license'] = license;
    if (birthDate != null) body['birth_date'] = birthDate.toIso8601String();

    try {
      final response = await http.put(
        Uri.parse(Endpoints.updateUser),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao atualizar perfil: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exceção no updateProfile: $e');
      return false;
    }
  }
}