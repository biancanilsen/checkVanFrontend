import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';
import '../services/navigation_service.dart';

class PresenceProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  bool _isConfirming = false;
  bool get isConfirming => _isConfirming;

  String? error;

  Map<String, String?> _monthlyPresence = {};
  Map<String, String?> get monthlyPresence => _monthlyPresence;

  final Set<String> _fetchedMonths = {};

  Future<void> getMonthlyPresence(int studentId, DateTime date) async {
    final monthKey = '${studentId}_${DateFormat('yyyy-MM').format(date)}';

    if (_fetchedMonths.contains(monthKey)) {
      return;
    }

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await _client.get(
        Uri.parse(Endpoints.getMonthlyPresence(studentId, date.year, date.month)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _fetchedMonths.add(monthKey);

        final List<dynamic> data = jsonDecode(response.body);

        // Preenche o mapa. Nota: Se limparmos o mapa ao trocar de aluno,
        // isso aqui vai repopular corretamente.
        for (var item in data) {
          _monthlyPresence[item['date']] = item['status'];
        }

        notifyListeners();

      } else {
        print('Falha ao carregar presença do mês $monthKey.');
      }
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
    } catch (e) {
      error = e.toString();
      _monthlyPresence = {};
      print('Erro em getMonthlyPresence: $e');
    }
  }

  Future<bool> updatePresence({
    required int studentId,
    required DateTime date,
    required String status,
  }) async {
    _isConfirming = true;
    error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) {
        error = 'Sessão expirada. Faça login novamente.';
        return false;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _client.put(
        Uri.parse(Endpoints.updatePresence(studentId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': formattedDate,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _monthlyPresence[formattedDate] = status;

        // Atualiza o cache também para garantir consistência
        final monthKey = '${studentId}_${DateFormat('yyyy-MM').format(date)}';
        _fetchedMonths.add(monthKey);

        return true;
      } else {
        final resp = jsonDecode(response.body) as Map<String, dynamic>;
        error = resp['message'] as String? ?? 'Falha ao atualizar presença.';
        return false;
      }
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } catch (e) {
      error = 'Erro de conexão. Verifique sua internet.';
      return false;
    } finally {
      _isConfirming = false;
      notifyListeners();
    }
  }

  void clearMonthlyPresence() {
    _monthlyPresence = {};
    _fetchedMonths.clear();
    notifyListeners();
  }
}