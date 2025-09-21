import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/van_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class VanProvider extends ChangeNotifier {
  List<Van> _vans = [];
  bool _isLoading = false;
  String? _error;

  List<Van> get vans => _vans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createVan({
    required String nickname,
    required String plate,
    required int capacity,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final body = {
        'nickname': nickname,
        'plate': plate,
        'capacity': capacity,
      };

      final response = await http.post(
        Uri.parse(Endpoints.createVan),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // Opcional: Adicionar a nova van à lista local ou recarregar todas as vans.
        // await getVans();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao cadastrar van.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

