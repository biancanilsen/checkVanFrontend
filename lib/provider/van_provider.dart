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

  Future<void> getVans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.get(
        Uri.parse(Endpoints.getAllVans),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> vanListJson = data['vans'];
        _vans = vanListJson.map((json) => Van.fromJson(json)).toList();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Falha ao carregar vans.';
        _vans = [];
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      _vans = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchVans(String term) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final uri = Uri.parse('${Endpoints.searchVans}?term=${Uri.encodeComponent(term)}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> vanListJson = data['vans'];
        _vans = vanListJson.map((json) => Van.fromJson(json)).toList();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Falha ao buscar vans.';
        _vans = [];
      }
    } catch (e) {
      _error = e.toString();
      _vans = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
        await getVans();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao cadastrar van.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVan({
    required int id,
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

      final response = await http.put(
        Uri.parse('${Endpoints.updateVan}/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await getVans();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao atualizar van.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}