import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../model/student_model.dart';
import '../../../model/team_model.dart';
import '../../../provider/student_provider.dart';
import '../../widgets/utils/page_search_bar.dart';
import '../../widgets/student/student_tile.dart';
import '../student/add_student_page.dart';

class TeamDetailPage extends StatefulWidget {
  final Team team;

  const TeamDetailPage({super.key, required this.team});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  late List<Student> _allStudents;
  late List<Student> _filteredStudents;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _allStudents = widget.team.students;
    _filteredStudents = _allStudents;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final lowerQuery = query.toLowerCase().trim();
      if (lowerQuery.isEmpty) {
        setState(() {
          _filteredStudents = _allStudents;
        });
        return;
      }

      final filtered = _allStudents.where((student) {
        return student.name.toLowerCase().contains(lowerQuery);
      }).toList();

      setState(() {
        _filteredStudents = filtered;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: AppPalette.primary900,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageSearchBar(
              hintText: 'Pesquisar aluno na turma',
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _filteredStudents.isEmpty
                ? const Center(
              child: Text('Nenhum aluno encontrado.'),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: StudentTile(
                    name: student.name,
                    // O 'student' que vem da 'team' não tem 'address'
                    // Você pode querer buscar o 'student' completo
                    // ou ajustar o modelo
                    address: student.address ?? 'Endereço não disponível',
                    image_profile: student.image_profile,
                    isGuardian: false,
                    onActionPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (newContext) => ChangeNotifierProvider.value(
                            // --- 2. CORREÇÃO AQUI ---
                            // Lê o StudentProvider do contexto
                            value: context.read<StudentProvider>(),
                            child: AddStudentPage(student: student),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

