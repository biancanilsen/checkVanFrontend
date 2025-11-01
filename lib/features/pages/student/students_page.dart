// features/pages/student/students_page.dart

import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/student_provider.dart';
// REMOVA O IMPORT DO 'EditStudentForm'
// import '../../forms/edit_student_form.dart';
// 1. IMPORTE A PÁGINA 'AddStudentPage'
import 'add_student_page.dart';
import '../../widgets/student/student_tile.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final StudentProvider _studentProvider = StudentProvider();

  @override
  void initState() {
    super.initState();
    _studentProvider.getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _studentProvider,
      child: SafeArea(
        child: Stack(
          children: [
            _buildStudentList(),

            // Botão Fixo "+ Adicionar aluno"
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Adicionar aluno',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    // 2. NAVEGAÇÃO PARA ADICIONAR
                    // Precisamos passar o provider para a nova página
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (newContext) => ChangeNotifierProvider.value(
                          value: _studentProvider, // Passa o provider existente
                          child: const AddStudentPage(student: null), // student: null = modo de criação
                        ),
                      ),
                    );
                    // Esta rota antiga não vai funcionar com o provider
                    // Navigator.pushNamed(context, '/add-student');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary800,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) { // 'provider' está disponível aqui
        if (provider.isLoading && provider.students.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        if (provider.students.isEmpty && !provider.isLoading) {
          return const Center(child: Text('Nenhum aluno cadastrado.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          itemCount: provider.students.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const PageHeader(title: 'Meus alunos');
            }

            if (index == 1) {
              return PageSearchBar(
                hintText: 'Pesquisar turma ou aluno',
                onChanged: (value) {
                  // provider.filterStudents(value);
                },
              );
            }

            final student = provider.students[index - 2];
            return StudentTile(
              name: student.name,
              address: student.address,
              // 3. ATUALIZE O onEditPressed
              onEditPressed: () {
                // Remove o showDialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (newContext) => ChangeNotifierProvider.value(
                      value: provider, // Passa o provider
                      child: AddStudentPage(student: student), // Passa o aluno para edição
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}