import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/student_provider.dart';
import '../../../utils/user_session.dart';
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

  // 2. Adicione variáveis de estado para a role
  String? _userRole;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _studentProvider.getStudents();
    _loadUserRole(); // <-- 3. Chame a função para carregar a role
  }

  // 4. Crie a função para carregar a role
  Future<void> _loadUserRole() async {
    final user = await UserSession.getUser();
    if (mounted) {
      setState(() {
        _userRole = user?.role;
        _isLoadingRole = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. Se estiver carregando a role, mostre um loading
    if (_isLoadingRole) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isGuardian = _userRole == 'guardian';

    return ChangeNotifierProvider.value(
      value: _studentProvider,
      child: SafeArea(
        child: Stack(
          children: [
            // 6. Passe a role para o método que constrói a lista
            _buildStudentList(isGuardian),

            // 7. Mostre o botão de adicionar APENAS se for guardian
            if (isGuardian)
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (newContext) => ChangeNotifierProvider.value(
                            value: _studentProvider,
                            child: const AddStudentPage(student: null),
                          ),
                        ),
                      );
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

  // 8. Aceite a role como parâmetro
  Widget _buildStudentList(bool isGuardian) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.students.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        // ... (outros 'if' de erro/vazio)

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 0, 16, isGuardian ? 90 : 16), // Padding dinâmico
          itemCount: provider.students.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const PageHeader(title: 'Meus alunos');
            }
            if (index == 1) {
              return PageSearchBar(
                hintText: 'Pesquisar turma ou aluno',
                onChanged: (value) { /* ... */ },
              );
            }

            final student = provider.students[index - 2];
            return StudentTile(
              name: student.name,
              address: student.address,
              isGuardian: isGuardian, // <-- 9. Passe a role para o tile
              onActionPressed: () { // Ação é a mesma (abrir a página)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (newContext) => ChangeNotifierProvider.value(
                      value: provider,
                      child: AddStudentPage(student: student),
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