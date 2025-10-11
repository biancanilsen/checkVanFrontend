import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/student_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Busca a lista de alunos do backend.
  /// A lista varia conforme o tipo de usuário (motorista ou responsável).
  Future<void> getStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await UserSession.getUser();
      if (user?.role == null) throw Exception('Não foi possível identificar o tipo de usuário.');

      // Define o endpoint correto com base na role do usuário
      final endpointUrl = user!.role == 'driver' ? Endpoints.getAllStudents : Endpoints.getStudents;
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.get(
        Uri.parse(endpointUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> studentListJson = data['students'];
        _students = studentListJson.map((json) => Student.fromJson(json)).toList();
        // Ordena a lista em ordem alfabética para exibição consistente
        _students.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (response.statusCode == 404) {
        _students = []; // Limpa a lista se não encontrar nada
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Falha ao carregar alunos.');
      }
    } catch (e) {
      _error = e.toString();
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona um novo aluno.
  Future<bool> addStudent({
    required String name,
    required DateTime birthDate,
    required String gender,
    required int schoolId,
    required String address,
    required String shiftGoing,
    required String shiftReturn,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.post(
        Uri.parse(Endpoints.createStudent),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'birth_date': DateFormat('yyyy-MM-dd').format(birthDate),
          'gender': gender,
          'school_id': schoolId,
          'address': address,
          'shift_going': shiftGoing,
          'shift_return': shiftReturn,
        }),
      );

      if (response.statusCode == 201) {
        await getStudents(); // Atualiza a lista local após o sucesso
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erro ao adicionar aluno.');
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza os dados de um aluno existente.
  /// Retorna `true` em caso de sucesso.
  Future<bool> updateStudent({
    required int id,
    required String name,
    required DateTime birthDate,
    required String gender,
    required int schoolId,
    required String address,
    required String shiftGoing,
    required String shiftReturn,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.put(
        Uri.parse('${Endpoints.updateStudent}/$id'), // O ID é passado na URL
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'birth_date': DateFormat('yyyy-MM-dd').format(birthDate),
          'gender': gender,
          'school_id': schoolId,
          'address': address,
          'shift_going': shiftGoing,   // AJUSTE: Adicionado campo de turno
          'shift_return': shiftReturn, // AJUSTE: Adicionado campo de turno
        }),
      );

      if (response.statusCode == 200) {
        await getStudents(); // Recarrega a lista para refletir a alteração
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erro ao atualizar aluno.');
      }
    } catch (e) {
      _error = e.toString();
      return false; // AJUSTE: Retorna `false` em caso de erro
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exclui um aluno.
  /// Retorna `true` em caso de sucesso.
  Future<bool> deleteStudent(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // AJUSTE: A melhor prática para DELETE é passar o ID na URL, sem corpo (body).
      // Isso é mais seguro e segue o padrão RESTful.
      final response = await http.delete(
        Uri.parse('${Endpoints.deleteStudent}/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // AJUSTE: Remove o aluno da lista localmente para uma resposta de UI mais rápida,
        // antes de recarregar a lista completa do servidor.
        _students.removeWhere((student) => student.id == studentId);
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erro ao excluir aluno.');
      }
    } catch (e) {
      _error = e.toString();
      return false; // AJUSTE: Retorna `false` em caso de erro
    } finally {
      _isLoading = false;
      notifyListeners();
      // Opcional: recarregar a lista para garantir consistência total.
      // await getStudents();
    }
  }

// O método `getAllStudentsForDriver` foi removido pois sua lógica
// já está contida de forma mais eficiente dentro do `getStudents`.
}