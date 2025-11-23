import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../network/endpoints.dart';
import '../services/navigation_service.dart';

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
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        error = null;
        return true;
      } else {
        error = 'Erro ao enviar email';
        return false;
      }
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } catch (e) {
      NavigationService.forceErrorScreen();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}