import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  /// Realiza login, salva token e dados do usuário em sessão
  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      // 1) Chamada de login
      final loginResponse = await http.post(
        Uri.parse(Endpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (loginResponse.statusCode == 200) {
        final body = jsonDecode(loginResponse.body) as Map<String, dynamic>;
        final token = body['token'] as String;

        // 2) Salva o token
        await UserSession.saveToken(token);

        // 3) Busca dados do perfil autenticado
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

          // 4) Salva os dados do usuário em sessão
          await UserSession.saveUser(user);

          error = null;
          return true;
        } else {
          // Falha ao obter perfil
          error = 'Falha ao obter dados do perfil';
          return false;
        }
      } else {
        // Login inválido
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
