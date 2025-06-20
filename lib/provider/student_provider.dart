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

  Future<void> getStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await UserSession.getUser();
      final role = user?.role?.toUpperCase();

      if (user == null || role == null) {
        throw Exception('Não foi possível identificar o tipo de usuário.');
      }

      String endpointUrl;
      if (role == 'DRIVER') {
        endpointUrl = Endpoints.getAllStudents;
      } else {
        endpointUrl = Endpoints.getStudents;
      }

      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // 3. Usar a URL do endpoint escolhido na chamada HTTP
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

        _students.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        _error = null;
      } else if (response.statusCode == 404) {
        _students = [];
        _error = null;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Falha ao carregar alunos.';
        _students = [];
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> addStudent(String nome, DateTime dataNascimento, String gender) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final body = {
        'name': nome,
        'birth_date': DateFormat('yyyy-MM-dd').format(dataNascimento),
        'gender': gender,
      };

      final response = await http.post(
        Uri.parse(Endpoints.registration),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        await getStudents();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao adicionar aluno.';
        await getStudents();
      }
    } catch (e) {
      _error = 'Erro de conexão ao adicionar: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateStudent(int id, String name, DateTime birthDate, String gender) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final body = {
        'id': id,
        'name': name,
        'birth_date': DateFormat('yyyy-MM-dd').format(birthDate),
        'gender': gender,
      };

      final response = await http.put(
        Uri.parse(Endpoints.updateStudent),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await getStudents();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao atualizar aluno.';
        await getStudents();
      }
    } catch (e) {
      _error = 'Erro de conexão ao atualizar: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final body = {
        'studentId': studentId,
      };

      final response = await http.delete(
        Uri.parse(Endpoints.deleteStudent),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await getStudents();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao deletar aluno.';
        await getStudents();
      }
    } catch (e) {
      _error = 'Erro de conexão ao deletar: ${e.toString()}';
      notifyListeners();
    }
  }
}