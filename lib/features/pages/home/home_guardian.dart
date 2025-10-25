import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:check_van_frontend/core/theme.dart';

import '../../../provider/student_provider.dart';
import '../../../utils/user_session.dart';
import '../../widgets/home/homeGuaridan/confirm_presence_callout.dart';
import '../../widgets/home/homeGuaridan/guardian_bottom_nav_bar.dart';
import '../../widgets/home/homeGuaridan/guardian_home_header.dart';
import '../../widgets/home/homeGuaridan/presence_student_card.dart';
import '../attendance/confirm_attendance_page.dart';


class HomeGuardian extends StatefulWidget {
  const HomeGuardian({super.key});

  @override
  State<HomeGuardian> createState() => _HomeGuardianState();
}

class _HomeGuardianState extends State<HomeGuardian> {
  String _greeting = 'Olá,';
  String _userName = 'Usuário';

  // 3. ADICIONE O ÍNDICE DA NAVEGAÇÃO
  int _selectedIndex = 0; // 0 = Presença, 1 = Alunos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().getPresenceSummary();
      _loadUserAndGreeting();
    });
  }

  // 4. ADICIONE O MÉTODO DE NAVEGAÇÃO
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
      // 'Presença' - Já estamos aqui
      // (Se esta tela for um "wrapper", você pode trocar o body aqui)
        break;
      case 1:
      // 'Alunos'
        Navigator.pushNamed(context, '/students');
        break;
    }
    // Nota: Se a tela '/students' for uma tela principal,
    // você pode querer gerenciar o estado do _selectedIndex de forma diferente
    // (talvez com um PageView ou um provider de navegação).
  }

  Future<void> _loadUserAndGreeting() async {
    final user = await UserSession.getUser();
    final name = user?.name?.isNotEmpty == true ? user!.name : 'Usuário';
    final hour = DateTime.now().hour;
    final greeting =
    hour < 12 ? 'Bom dia,' : hour < 18 ? 'Boa tarde,' : 'Boa noite,';
    if (!mounted) return;
    setState(() {
      _greeting = greeting;
      _userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,

      // 5. ADICIONE A BARRA DE NAVEGAÇÃO AO SCAFFOLD
      bottomNavigationBar: GuardianBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              GuardianHomeHeader(
                greeting: _greeting,
                userName: _userName,
              ),

              const SizedBox(height: 20),

              // School Bus Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/school_bus.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              // Callout
              const ConfirmPresenceCallout(),

              const SizedBox(height: 24),

              // Título "Confirmação de presença"
              Text(
                'Confirmação de presença',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppPalette.neutral900,
                ),
              ),
              const SizedBox(height: 12),

              // Lista de Alunos (Consumer)
              Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.error != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        provider.error!,
                        style: textTheme.bodyMedium?.copyWith(color: Colors.red),
                      ),
                    );
                  }

                  final students = provider.presenceSummaryStudents;
                  if (students.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Nenhum aluno encontrado.',
                        style: textTheme.bodyMedium,
                      ),
                    );
                  }

                  return Column(
                    children: students.map(
                          (s) => PresenceStudentCard(
                        name: s.name,
                        isConfirmed: s.isPresenceConfirmed,
                        imageUrl: s.imageProfile,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmAttendancePage(
                                studentId: s.id,
                                studentName: s.name,
                                studentImageUrl: s.imageProfile,
                              ),
                            ),
                          );
                        },
                      ),
                    ).toList(),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}