import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../network/endpoints.dart';

class ForgotPasswordProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;

  Future<bool> sendRecoveryEmail(String email) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(Endpoints.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = 'Erro ao enviar email';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}