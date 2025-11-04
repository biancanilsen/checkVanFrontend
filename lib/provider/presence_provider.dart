import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../network/endpoints.dart';
import '../utils/user_session.dart';

class PresenceProvider extends ChangeNotifier {
  // ATUALIZADO: Renomeado para ser específico
  bool _isConfirming = false;
  bool get isConfirming => _isConfirming; // Usar isso no botão 'Confirmar'

  String? error;

  Map<String, String?> _monthlyPresence = {};
  Map<String, String?> get monthlyPresence => _monthlyPresence;

  // ADICIONADO: "Cache" para saber quais meses já buscamos (Ex: "2025-11", "2025-12")
  final Set<String> _fetchedMonths = {};

  // ATUALIZADO: Agora aceita um DateTime para saber qual mês buscar
  Future<void> getMonthlyPresence(int studentId, DateTime date) async {
    // Cria uma chave única para o mês/ano (Ex: "2025-11")
    final monthKey = DateFormat('yyyy-MM').format(date);

    // 1. VERIFICA O CACHE: Se já buscamos, não faz nada.
    if (_fetchedMonths.contains(monthKey)) {
      return;
    }

    // 2. Não ativa o 'isLoading' global. A busca é silenciosa.
    //    A UI vai mostrar "relógio" até os dados chegarem.

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // 3. ATUALIZADO: Chama o endpoint com ano e mês
      //    Lembre-se da correção do backend (passo 1 da resposta anterior)
      //    e do endpoint.dart (passo 2)
      final response = await http.get(
        Uri.parse(Endpoints.getMonthlyPresence(studentId, date.year, date.month)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // 4. Marca o mês como buscado (em caso de sucesso)
        _fetchedMonths.add(monthKey);

        final List<dynamic> data = jsonDecode(response.body);

        // 5. ATUALIZADO: Adiciona ao mapa, NÃO limpa o mapa antigo
        for (var item in data) {
          _monthlyPresence[item['date']] = item['status'];
        }

        // 6. Notifica a UI para atualizar os ícones
        notifyListeners();

      } else {
        // Não define um 'error' global para não quebrar a tela de confirmação
        print('Falha ao carregar presença do mês $monthKey.');
      }
    } catch (e) {
      error = e.toString();
      _monthlyPresence = {};
      print('Erro em getMonthlyPresence: $e');
    }
    // 7. SEM 'finally' e SEM 'notifyListeners()' aqui
    //    A notificação só acontece em caso de SUCESSO.
  }

  // ATUALIZADO: Usa o _isConfirming
  Future<bool> updatePresence({
    required int studentId,
    required DateTime date,
    required String status,
  }) async {
    _isConfirming = true; // ATUALIZADO
    error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) {
        error = 'Sessão expirada. Faça login novamente.';
        return false;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await http.put(
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
        _monthlyPresence[formattedDate] = status;

        // ADICIONADO: Se atualizou o status, força o mês como "buscado"
        // para não sobrescrever a mudança local.
        final monthKey = DateFormat('yyyy-MM').format(date);
        _fetchedMonths.add(monthKey);

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
      _isConfirming = false; // ATUALIZADO
      notifyListeners();
    }
  }
}