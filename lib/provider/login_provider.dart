import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/driver_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(Endpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];

        await UserSession.saveToken(token);
        error = null;

        return true;
      } else {
        error = jsonDecode(response.body)['message'];
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

