import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../model/student_model.dart';
import '../model/student_presence_summary.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  List<StudentPresenceSummary> _presenceSummaryStudents = [];
  bool _isLoading = false;
  String? _error;
  String? _tripStatus;
  bool _isStatusLoading = false;

  String? get tripStatus => _tripStatus;
  bool get isStatusLoading => _isStatusLoading;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<StudentPresenceSummary> get presenceSummaryStudents => _presenceSummaryStudents;

  Future<void> getPresenceSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.get(
        Uri.parse(Endpoints.getPresenceSummary),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _presenceSummaryStudents = data.map((json) => StudentPresenceSummary.fromJson(json)).toList();
        _presenceSummaryStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Falha ao carregar o resumo de presença.');
      }
    } catch (e) {
      _error = e.toString();
      _presenceSummaryStudents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    XFile? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final createResponse = await http.post(
        Uri.parse(Endpoints.createStudent),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'birth_date': birthDate.toIso8601String(),
          'gender': gender,
          'school_id': schoolId,
          'address': address,
          'shift_going': shiftGoing,
          'shift_return': shiftReturn,
        }),
      );

      final data = jsonDecode(createResponse.body);

      if (createResponse.statusCode != 201) {
        throw Exception(data['message'] ?? 'Erro ao adicionar aluno.');
      }

      if (imageFile != null) {
        final int studentId = data['student']['id'];

        final uploadUrl = Uri.parse('${Endpoints.baseUrl}/student/$studentId/upload-image'); // Ajuste o endpoint base

        final request = http.MultipartRequest('POST', uploadUrl);
        request.headers['Authorization'] = 'Bearer $token';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image_profile',
            imageFile.path,
            contentType: MediaType('image', imageFile.path.split('.').last),
          ),
        );

        final streamedResponse = await request.send();
        final uploadResponse = await http.Response.fromStream(streamedResponse);

        if (uploadResponse.statusCode != 200) {
          print('Aluno criado, mas o upload da imagem falhou: ${uploadResponse.body}');
        }
      }

      await getStudents();
      return true;

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
    // Campos do Guardian
    required String name,
    required DateTime birthDate,
    required String gender,
    required String address,
    XFile? imageFile,

    // Campos do Driver (Logísticos)
    required int schoolId,
    required String shiftGoing,
    required String shiftReturn,
    int? teamId, // <-- ADICIONE
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // O backend agora aceita o upload de imagem no 'update'
      // (Baseado na sua lógica do 'addStudent')
      // Se houver um 'imageFile', faça o upload primeiro
      if (imageFile != null) {
        final uploadUrl = Uri.parse('${Endpoints.baseUrl}/student/$id/upload-image');
        final request = http.MultipartRequest('POST', uploadUrl);
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_profile',
            imageFile.path,
            contentType: MediaType('image', imageFile.path.split('.').last),
          ),
        );
        final streamedResponse = await request.send();
        final uploadResponse = await http.Response.fromStream(streamedResponse);

        if (uploadResponse.statusCode != 200) {
          print('Upload da imagem falhou: ${uploadResponse.body}');
          // Decide se quer continuar mesmo se o upload falhar
        }
      }

      // Em seguida, atualize os dados de texto
      final response = await http.put(
        Uri.parse('${Endpoints.updateStudent}/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'birth_date': birthDate.toIso8601String(),
          'gender': gender,
          'school_id': schoolId,
          'address': address,
          'shift_going': shiftGoing,
          'shift_return': shiftReturn,
          'team_id': teamId, // <-- PASSE O ID DA TURMA
        }),
      );

      if (response.statusCode == 200) {
        await getStudents(); // Recarrega a lista de alunos
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

  Future<void> searchStudents(String name) async {
    _isLoading = true;
    _error = null;
    // Notifica os ouvintes para mostrar o loading
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // O backend já cuida da lógica de role (guardian/driver)
      // O 'name' é enviado como um query parameter
      final uri = Uri.parse('${Endpoints.searchStudents}?name=${Uri.encodeComponent(name)}');

      final response = await http.get(
        uri,
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
        throw Exception(data['message'] ?? 'Falha ao buscar alunos.');
      }
    } catch (e) {
      _error = e.toString();
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextTripStatus() async {
    _isStatusLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_students.isEmpty) {
        await getStudents();
      }

      if (_students.isEmpty) {
        _tripStatus = 'NAO_VAI';
        _isStatusLoading = false;
        notifyListeners();
        return;
      }

      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final studentIds = _students.map((s) => s.id).toList();

      final response = await http.post(
        Uri.parse(Endpoints.getNextTripStatusBulk),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'studentIds': studentIds}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _tripStatus = data['status'];
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Falha ao carregar status da viagem.');
      }
    } catch (e) {
      _error = e.toString();
      _tripStatus = 'NAO_VAI';
    } finally {
      _isStatusLoading = false;
      notifyListeners();
    }
  }

  Future<Student> getStudentDetails(int studentId) async {
    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final url = Uri.parse('${Endpoints.baseUrl}/student/get/$studentId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final studentJson = data['student'];
        return Student.fromJson(studentJson);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Falha ao carregar dados do aluno.');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
}