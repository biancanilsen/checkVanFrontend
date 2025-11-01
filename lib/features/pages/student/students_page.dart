import 'dart:async';
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
  // 1. REMOVA a instância local do provider
  // final StudentProvider _studentProvider = StudentProvider();

  Timer? _debounce;
  String? _userRole;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2. LEIA o provider que foi injetado pelo Shell
      // (DriverShell ou GuardianShell)
      context.read<StudentProvider>().getStudents();
      _loadUserRole();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

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
    if (_isLoadingRole) {
      // É seguro ter um Scaffold aqui para a tela de loading
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isGuardian = _userRole == 'guardian';

    // 3. REMOVA o 'ChangeNotifierProvider.value'
    // O Consumer abaixo encontrará o provider injetado pelo Shell.
    return ColoredBox(
      color: AppPalette.appBackground,
      child: SafeArea(
        child: Stack(
          children: [
          _buildStudentList(isGuardian),

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
                          // 4. PASSE o provider lido do context
                          value: context.read<StudentProvider>(),
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

  Widget _buildStudentList(bool isGuardian) {
    // 5. O Consumer agora lê o provider do Shell
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.students.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        // Esta verificação agora funciona, pois 'provider' é a instância correta
        if (provider.students.isEmpty && !provider.isLoading) {
          return const Center(child: Text('Nenhum aluno cadastrado.'));
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 0, 16, isGuardian ? 90 : 16),
          // +2 para Header e SearchBar
          itemCount: provider.students.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const PageHeader(title: 'Meus alunos');
            }
            if (index == 1) {
              return PageSearchBar(
                hintText: 'Pesquisar turma ou aluno',
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    // Chama o search no provider correto
                    provider.searchStudents(value);
                  });
                },
              );
            }

            final student = provider.students[index - 2];
            return StudentTile(
              name: student.name,
              address: student.address,
              image_profile: student.image_profile,
              isGuardian: isGuardian,
              onActionPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (newContext) => ChangeNotifierProvider.value(
                      // 6. PASSE o 'provider' do Consumer
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