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
      if (user?.role == null) throw Exception('Não foi possível identificar o tipo de usuário.');

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
        _students.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (response.statusCode == 404) {
        _students = [];
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
        await getStudents();
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
        Uri.parse('${Endpoints.updateStudent}/$id'),
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

      if (response.statusCode == 200) {
        await getStudents();
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erro ao atualizar aluno.');
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteStudent(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.delete(
        Uri.parse('${Endpoints.deleteStudent}/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _students.removeWhere((student) => student.id == studentId);
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erro ao excluir aluno.');
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}