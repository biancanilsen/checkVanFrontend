import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/features/pages/confirm_attendance_page.dart';

import '../../provider/student_provider.dart';
import '../../utils/user_session.dart';
import '../widgets/home/confirm_presence_callout.dart';
import '../widgets/home/guardian_home_header.dart';
import '../widgets/home/presence_student_card.dart';

class HomeGuardian extends StatefulWidget {
  const HomeGuardian({super.key});

  @override
  State<HomeGuardian> createState() => _HomeGuardianState();
}

class _HomeGuardianState extends State<HomeGuardian> {
  String _greeting = 'Olá,';
  String _userName = 'Usuário';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().getPresenceSummary();
      _loadUserAndGreeting();
    });
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GuardianHomeHeader(
                greeting: _greeting,
                userName: _userName,
                // imageUrl: _userImageUrl, // TODO - substituir por imagem do cadastro
              ),

              const SizedBox(height: 20),

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

              const ConfirmPresenceCallout(),

              const SizedBox(height: 24),

              Text(
                'Confirmação de presença',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppPalette.neutral900,
                ),
              ),
              const SizedBox(height: 12),

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
                          (s) => PresenceStudentCard( // Usa o novo componente
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
