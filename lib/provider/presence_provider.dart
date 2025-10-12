import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../network/endpoints.dart';
import '../utils/user_session.dart';

class PresenceProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  Future<bool> updatePresence({
    required int studentId,
    required DateTime date,
    required String status,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) {
        error = 'Sessão expirada. Faça login novamente.';
        return false;
      }

      // Formata a data para o padrão YYYY-MM-DD esperado pelo backend
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await http.put(
        // Supondo que você tenha um endpoint dinâmico
        Uri.parse(Endpoints.updatePresence(studentId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': formattedDate,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final resp = jsonDecode(response.body) as Map<String, dynamic>;
        error = resp['message'] as String? ?? 'Falha ao atualizar presença.';
        return false;
      }
    } catch (e) {
      error = 'Erro de conexão. Verifique sua internet.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}