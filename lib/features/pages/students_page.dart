import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart'; // Importe seu tema para usar as cores
import '../../model/student_model.dart';
import '../../model/user_model.dart';
import '../../provider/school_provider.dart';
import '../../provider/student_provider.dart';
import '../../utils/user_session.dart';
import '../forms/edit_student_form.dart';
import '../forms/student_form.dart';
import 'teams_tab_view.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  UserModel? _user;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndInitTabs();
  }

  Future<void> _loadUserDataAndInitTabs() async {
    final user = await UserSession.getUser();
    if (!mounted) return;

    final bool isDriver = user?.role?.toUpperCase() == 'DRIVER';
    final int tabCount = isDriver ? 2 : 1;

    _tabController = TabController(length: tabCount, vsync: this);

    setState(() {
      _user = user;
      _isLoadingUser = false;
    });

    Provider.of<StudentProvider>(context, listen: false).getStudents();
    Provider.of<SchoolProvider>(context, listen: false).getSchools();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gestão de Alunos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List<Tab> tabs = [
      const Tab(icon: Icon(Icons.person), text: 'Alunos'),
    ];
    if (_user?.role?.toUpperCase() == 'DRIVER') {
      tabs.add(const Tab(icon: Icon(Icons.group), text: 'Turmas'));
    }

    final List<Widget> tabViews = [
      const StudentRegistrationView(),
    ];
    if (_user?.role?.toUpperCase() == 'DRIVER') {
      tabViews.add(const TeamsTabView());
    }

    return Scaffold(
      backgroundColor: AppColors.cinzaClaro, // Cor de fundo da página
      appBar: AppBar(
        title: const Text('Gestão de Alunos'),
        bottom: _tabController!.length > 1
            ? TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: tabs,
        )
            : null,
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabViews,
      ),
    );
  }
}

/// Conteúdo da aba "Alunos"
class StudentRegistrationView extends StatelessWidget {
  const StudentRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulário dentro de um Card para o novo design
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: StudentForm(),
              ),
            ),
            const SizedBox(height: 24),

            // Lista de alunos
            Consumer<StudentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.students.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(child: Text('Erro: ${provider.error!}'));
                }
                if (provider.students.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum aluno cadastrado.'),
                    ),
                  );
                }
                return StudentTable(students: provider.students);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Tabela que exibe a lista de alunos
class StudentTable extends StatelessWidget {
  final List<Student> students;

  const StudentTable({required this.students, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: students.map((s) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(s.name),
            subtitle: Text('Escola: ${s.school?.name ?? "Não informada"}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  onPressed: () {
                    // Lógica para abrir o dialog de edição
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    // Lógica para abrir o dialog de deleção
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}