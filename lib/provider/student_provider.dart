import 'package:flutter/material.dart';
import '../model/student_model.dart';

class StudentProvider extends ChangeNotifier {
  final List<Student> students = [];
  bool isLoading = false;
  String? error;
  int _nextId = 1;

  List<Student> get alunos => students;

  Future<void> addStudent(String nome, DateTime dataNascimento) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simula atraso do backend

    try {
      // Simula sucesso
      final novoAluno = Student(
        // id: _nextId++,
        name: nome,
        birthDate: dataNascimento,
      );
      students.add(novoAluno);
      error = null;
    } catch (e) {
      error = 'Erro ao adicionar aluno';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // void removerAluno(int id) {
  //   students.removeWhere((aluno) => aluno.id == id);
  //   notifyListeners();
  // }
}
