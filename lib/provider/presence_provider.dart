import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../network/endpoints.dart';
import '../utils/user_session.dart';

class PresenceProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  // ADICIONADO: Mapa para guardar os status do mês
  Map<String, String?> _monthlyPresence = {};
  Map<String, String?> get monthlyPresence => _monthlyPresence;

  // ADICIONADO: Método para buscar os status do mês para um aluno
  Future<void> getMonthlyPresence(int studentId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // Certifique-se de que este endpoint exista no seu arquivo 'endpoints.dart'
      // Ex: static String getMonthlyPresence(int id) => '$baseUrl/student/$id/presences/current-month';
      final response = await http.get(
        Uri.parse(Endpoints.getMonthlyPresence(studentId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Limpa o mapa antigo e preenche com os novos dados
        _monthlyPresence.clear();
        for (var item in data) {
          // Ex: {"2025-11-04": "GOING", "2025-11-05": "NONE", "2025-11-06": null}
          _monthlyPresence[item['date']] = item['status'];
        }
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Falha ao carregar presença do mês.');
      }
    } catch (e) {
      error = e.toString();
      _monthlyPresence = {}; // Limpa o mapa em caso de erro
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Seu método existente para ATUALIZAR a presença
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
        // ADICIONADO: Atualiza o mapa local após o sucesso
        _monthlyPresence[formattedDate] = status;

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