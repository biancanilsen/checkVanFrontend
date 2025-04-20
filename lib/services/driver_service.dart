import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/user_session.dart';
import '../network/endpoints.dart';

class DriverService {
  static Future<bool> updateProfile({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String license,
  }) async {
    final token = await UserSession.getToken();

    final body = {
      'driver_name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'driver_license': license,
    };

    print('🔼 Enviando dados para /driver/update:');
    print('Token: Bearer $token');
    print('Body: ${jsonEncode(body)}');

    final response = await http.put(
      Uri.parse(Endpoints.updateDriver),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('🔽 Resposta [${response.statusCode}]: ${response.body}');

    return response.statusCode == 200;
  }
}

