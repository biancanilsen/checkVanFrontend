import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final loginResponse = await http.post(
        Uri.parse(Endpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (loginResponse.statusCode == 200) {
        final body = jsonDecode(loginResponse.body) as Map<String, dynamic>;
        final token = body['token'] as String;

        await UserSession.saveToken(token);

        final profileResponse = await http.get(
          Uri.parse(Endpoints.getProfile),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (profileResponse.statusCode == 200) {
          final profileBody = jsonDecode(profileResponse.body) as Map<String, dynamic>;
          final userJson = profileBody['user'] as Map<String, dynamic>;
          final user = UserModel.fromJson(userJson);

          await UserSession.saveUser(user);

          error = null;
          return true;
        } else {
          error = 'Falha ao obter dados do perfil';
          return false;
        }
      } else {
        final resp = jsonDecode(loginResponse.body) as Map<String, dynamic>;
        error = resp['message'] as String? ?? 'Erro no login';
        return false;
      }
    } catch (e) {
      error = 'Erro de conexão';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
