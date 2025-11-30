import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../services/session_manager.dart';
import '../utils/user_session.dart';
import '../services/navigation_service.dart';

class LoginProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  bool isLoading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final loginResponse = await _client.post(
        Uri.parse(Endpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 60));

      if (loginResponse.statusCode == 200) {
        final body = jsonDecode(loginResponse.body) as Map<String, dynamic>;
        final token = body['token'] as String;

        await UserSession.saveToken(token);

        final profileResponse = await _client.get(
          Uri.parse(Endpoints.getProfile),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 30));

        if (profileResponse.statusCode == 200) {
          final profileBody = jsonDecode(profileResponse.body) as Map<String, dynamic>;
          final userJson = profileBody['user'] as Map<String, dynamic>;
          final user = UserModel.fromJson(userJson);

          await UserSession.saveUser(user);

          SessionManager().startSession();

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
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } catch (e) {
      print("Erro genérico no login: $e");
      NavigationService.forceErrorScreen();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}