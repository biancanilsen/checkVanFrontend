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

      final response = await http.get(
        Uri.parse(Endpoints.getAllSchools),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> schoolListJson = data['schools'];
        _schools = schoolListJson.map((json) => School.fromJson(json)).toList();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Falha ao carregar escolas.';
        _schools = [];
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      _schools = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSchool({
    required String name,
    required String address,
    String? morningLimit,
    String? morningDeparture,
    String? afternoonLimit,
    String? afternoonDeparture,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(Endpoints.createSchool);
      final token = await UserSession.getToken();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'address': address,
          'morning_limit': morningLimit,
          'morning_departure': morningDeparture,
          'afternoon_limit': afternoonLimit,
          'afternoon_departure': afternoonDeparture,
        }),
      );

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        await getSchools();
        return true;
      } else {
        _error = 'Falha ao cadastrar a escola.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ocorreu um erro: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchool({
    required int id,
    required String name,
    required String address,
    String? morningLimit,
    String? morningDeparture,
    String? afternoonLimit,
    String? afternoonDeparture,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('${Endpoints.updateSchool}/$id');
      final token = await UserSession.getToken();

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'address': address,
          'morning_limit': morningLimit,
          'morning_departure': morningDeparture,
          'afternoon_limit': afternoonLimit,
          'afternoon_departure': afternoonDeparture,
        }),
      );

      if (response.statusCode == 200) {
        await getSchools();
        return true;
      } else {
        _error = 'Falha ao atualizar a escola.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ocorreu um erro: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> searchSchools(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final uri = Uri.parse('${Endpoints.searchSchools}?name=${Uri.encodeComponent(name)}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> schoolListJson = data['schools'];
        _schools = schoolListJson.map((json) => School.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        _schools = [];
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Falha ao buscar escolas.');
      }
    } catch (e) {
      _error = e.toString();
      _schools = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSchool(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.delete(
        Uri.parse('${Endpoints.deleteSchool}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await getSchools();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao excluir escola.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

