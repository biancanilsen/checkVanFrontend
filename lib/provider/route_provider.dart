import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  /// Gera a rota otimizada, buscando os dados do backend.
  Future<bool> generateRoute({required int teamId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.get(
        Uri.parse('${Endpoints.generateRoute}/$teamId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --- CORREÇÃO ---
        // A lógica de parsing complexa agora está dentro do RouteData.fromJson.
        // O provider só precisa chamar o construtor de fábrica e ele faz todo o trabalho.
        _routeData = RouteData.fromJson(data);

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
