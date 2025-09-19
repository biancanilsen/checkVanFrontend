import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/student_model.dart';
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
        Uri.parse(Endpoints.getAllTeamsByDriver), // Endpoint para buscar turmas do motorista
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> teamListJson = data['teams'];
        _teams = teamListJson.map((json) => Team.fromJson(json)).toList();
      } else {
        _error = 'Falha ao carregar turmas.';
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTeam({required String name, required int tripId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final body = {'name': name, 'trip_id': tripId};

      final response = await http.post(
        Uri.parse(Endpoints.teamRegistration),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        await getTeams();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao adicionar turma.';
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTeam(int teamId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // O ID da turma é passado diretamente na URL, sem corpo (body)
      final response = await http.delete(
        Uri.parse('${Endpoints.deleteTeam}/$teamId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Se a deleção for bem-sucedida, atualiza a lista de turmas
        await getTeams();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao deletar turma.';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoading = false;
      // O getTeams() já chama o notifyListeners() no sucesso,
      // mas podemos chamar de novo para garantir que o estado de loading termine.
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  Future<bool> updateTeam({
    required int teamId,
    required String name,
    required int tripId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final body = {'name': name, 'trip_id': tripId};

      final response = await http.put(
        Uri.parse('${Endpoints.updateTeam}/$teamId'), // Passa o ID na URL
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await getTeams(); // Recarrega a lista
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao atualizar turma.';
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

  // Método para atribuir um aluno a uma turma
  Future<bool> assignStudentToTeam({required int studentId, required int teamId}) async {

    try {
      final token = await UserSession.getToken();
      // if (token == null) throw Exception('Usuário não autenticado.');

      final body = {'student_id': studentId, 'team_id': teamId};

      final response = await http.post(
        Uri.parse(Endpoints.assignStudentToTeam),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // Após atribuir, é uma boa prática recarregar os dados daquela turma
        // (Esta lógica será adicionada no próprio modal)
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao atribuir aluno.';
        notifyListeners(); // Notifica a UI sobre o erro
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<List<Student>> getStudentsForTeam(int teamId) async {
    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // Usa o endpoint que busca alunos por ID da turma
      final response = await http.get(
        Uri.parse('${Endpoints.getStudentsByTeamId}/$teamId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> studentListJson = data['students'] ?? [];
        return studentListJson.map((json) => Student.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar alunos da turma: $e');
      return [];
    }
  }

  Future<bool> unassignStudentFromTeam({required int studentId, required int teamId}) async {
    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final body = {
        'student_id': studentId,
        'team_id': teamId,
      };

      final response = await http.delete( // Usando o método DELETE
        Uri.parse(Endpoints.unassignStudentFromTeam),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true; // Sucesso
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao desvincular aluno.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}