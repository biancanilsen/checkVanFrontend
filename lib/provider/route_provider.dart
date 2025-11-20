import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/route_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class RouteProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  RouteData? _routeData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  RouteData? get routeData => _routeData;

  // --- MÉTODO ATUALIZADO ---
  // 1. Adicionado 'tripType' aos argumentos
  Future<bool> generateRoute({
    required int teamId,
    required String tripType, // Ex: "GOING" ou "RETURNING"
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final uri = Uri.parse('${Endpoints.generateRoute}/$teamId?date=$formattedDate');

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 2. Passado 'tripType' para o factory
        _routeData = RouteData.fromJson(data, teamId, tripType);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Falha ao gerar a rota.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}