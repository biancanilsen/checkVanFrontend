import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/student_provider.dart';
import '../../forms/edit_student_form.dart';
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
      child: SafeArea( // Sem Scaffold, usamos SafeArea
        child: Stack( // Stack para o botão fixo
          children: [
            _buildStudentList(),

            // 2. Botão Fixo "+ Adicionar aluno"
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
                    Navigator.pushNamed(context, '/add-student');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary800, // Cor do tema
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

  // Widget auxiliar para construir a lista de conteúdo
  Widget _buildStudentList() {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.students.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        if (provider.students.isEmpty && !provider.isLoading) {
          // TODO: Adicionar um estado de "Nenhum aluno" mais amigável
          return const Center(child: Text('Nenhum aluno cadastrado.'));
        }

        // ListView agora contém o header, busca e os itens
        return ListView.builder(
          // Padding na parte inferior para não ser coberto pelo botão
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          // +2 para o Header e a Barra de Busca
          itemCount: provider.students.length + 2,
          itemBuilder: (context, index) {
            // Item 0: Header "Meus alunos"
            if (index == 0) {
              return PageHeader(title: 'Meus alunos');
            }

            // Item 1: Barra de Busca
            if (index == 1) {
              return PageSearchBar(
                hintText: 'Pesquisar turma ou aluno',
                onChanged: (value) {
                  // Você pode adicionar sua lógica de filtro aqui
                  // provider.filterStudents(value);
                },
              );
            }

            // Itens da Lista de Alunos
            final student = provider.students[index - 2];
            return StudentTile(
              name: student.name,
              address: student.address,
              onEditPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return ChangeNotifierProvider.value(
                      value: provider,
                      child: AlertDialog(
                        title: const Text('Editar Aluno'),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: EditStudentForm(student: student),
                        ),
                        actions: [],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}