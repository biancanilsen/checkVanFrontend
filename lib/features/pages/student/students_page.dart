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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _userRole;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().getStudents();
      _loadUserRole();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isGuardian = _userRole == 'guardian';

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
                            value: context.read<StudentProvider>(),
                            child: const AddStudentPage(student: null),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.green600,
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
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.students.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        final bool isListEmpty = provider.students.isEmpty;

        final int itemCount = isListEmpty ? 3 : provider.students.length + 2;

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 0, 16, isGuardian ? 90 : 16),
          itemCount: itemCount,
          itemBuilder: (context, index) {

            if (index == 0) {
              return const PageHeader(title: 'Meus alunos');
            }

            if (index == 1) {
              return PageSearchBar(
                controller: _searchController, // Mantém o estado do texto
                hintText: 'Pesquisar turma ou aluno',
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    provider.searchStudents(value);
                  });
                },
              );
            }

            if (isListEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 60),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum aluno encontrado.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
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