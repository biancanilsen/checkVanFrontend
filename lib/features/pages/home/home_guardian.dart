import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:check_van_frontend/core/theme.dart';

import '../../../provider/student_provider.dart';
import '../../../utils/user_session.dart';
import '../../widgets/home/homeGuaridan/confirm_presence_callout.dart';
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
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().getPresenceSummary();
      _loadUserAndGreeting();
    });
  }

  Future<void> _navigateToProfile() async {
    await Navigator.pushNamed(context, '/my_profile');

    _loadUserAndGreeting();
  }

  Future<void> _loadUserAndGreeting() async {
    final user = await UserSession.getUser();
    final name = user?.name?.isNotEmpty == true ? user!.name : 'Usuário';
    final hour = DateTime.now().hour;
    final greeting =
    hour < 12 ? 'Bom dia,' : hour < 18 ? 'Boa tarde,' : 'Boa noite,';

    // TODO: Adicione 'image_profile' ao seu UserModel e UserSession.getUser()
    // final imageUrl = user?.image_profile;

    if (!mounted) return;
    setState(() {
      _greeting = greeting;
      _userName = name;
      // TODO _profileImageUrl = imageUrl; // Salve a URL da imagem
    });
  }

  void _logout() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Você tem certeza que deseja sair?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Sair'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await UserSession.signOutUser();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuardianHomeHeader(
              greeting: _greeting,
              userName: _userName,
              imageProfile: _profileImageUrl,
              onProfileTap: _navigateToProfile,
                onLogoutTap: _logout
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
    );
  }
}