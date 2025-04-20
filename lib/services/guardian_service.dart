import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/user_session.dart';
import '../../network/endpoints.dart';

class GuardianService {
  static Future<bool> updateProfile({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final token = await UserSession.getToken();

    final response = await http.put(
      Uri.parse(Endpoints.updateGuardian),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'guardian_name': name,
        'phone': phone,
        'email': email,
        'password': password,
      }),
    );

    return response.statusCode == 200;
  }
}
