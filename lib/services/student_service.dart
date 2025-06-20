import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/student_model.dart';

class StudentService {
  static Future<bool> saveStudent(Student student) async {
    final response = await http.post(
      Uri.parse('https://api.exemplo.com/alunos'),
      body: jsonEncode(student.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
