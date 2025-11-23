import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/team_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class TeamProvider extends ChangeNotifier {
  List<Team> _teams = [];
  bool _isLoading = false;
  String? _error;

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getTeams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.get(
        Uri.parse(Endpoints.getAllTeamsByDriver),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> teamListJson = data['teams'];
        _teams = teamListJson.map((json) => Team.fromJson(json)).toList();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Falha ao carregar turmas.';
        _teams = [];
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      _teams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTeam({
    required String name,
    required int schoolId,
    required String address,
    int? vanId,
    String? shift,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.post(
        Uri.parse(Endpoints.createTeam),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'school_id': schoolId,
          'address': address,
          'van_id': vanId,
          'shift': shift,
        }),
      );

      if (response.statusCode == 201) {
        await getTeams();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao adicionar turma.';
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

  Future<bool> updateTeam({
    required int id,
    required String name,
    required int schoolId,
    required String address,
    String? shift,
    int? vanId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.put(
        Uri.parse('${Endpoints.updateTeam}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'school_id': schoolId,
          'address': address,
          'van_id': vanId,
          'shift': shift,
        }),
      );

      if (response.statusCode == 200) {
        await getTeams(); // Recarrega a lista
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao atualizar turma.';
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

  // Novo método para Buscar
  Future<void> searchTeams(String name) async {
    // TODO: Adicionar /team/search no backend e Endpoints.dart
    // Por enquanto, filtra a lista local
    if (name.isEmpty) {
      await getTeams();
      return;
    }

    _isLoading = true;
    notifyListeners();

    // Filtro local (temporário)
    final allTeams = _teams;
    final filtered = allTeams.where((team) =>
    team.name.toLowerCase().contains(name.toLowerCase()) ||
        team.students.any((s) => s.name.toLowerCase().contains(name.toLowerCase()))
    ).toList();

    _teams = filtered;
    _isLoading = false;
    notifyListeners();
  }
}