import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/school_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class SchoolProvider extends ChangeNotifier {
  List<School> _schools = [];
  bool _isLoading = false;
  String? _error;

  List<School> get schools => _schools;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getSchools() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // Certifique-se de que este endpoint está no seu arquivo Endpoints.dart
      final response = await http.get(
        Uri.parse(Endpoints.listSchools),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> schoolListJson = jsonDecode(response.body);
        _schools = schoolListJson.map((json) => School.fromJson(json)).toList();
      } else {
        _error = 'Falha ao carregar escolas.';
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}