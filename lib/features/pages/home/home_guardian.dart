import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:check_van_frontend/core/theme.dart';

import '../../../provider/student_provider.dart';
import '../../../utils/user_session.dart';
import '../../widgets/home/homeGuaridan/confirm_presence_callout.dart';
import '../../widgets/home/homeGuaridan/guardian_home_header.dart'; // Importe o header
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
  String? _profileImageUrl; // Para guardar a URL da imagem

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usamos context.read() pois o provider é injetado pelo GuardianShell
      context.read<StudentProvider>().getPresenceSummary();
      _loadUserAndGreeting();
    });
  }

  // Função que navega e ESPERA o retorno da tela de perfil
  Future<void> _navigateToProfile() async {
    // Navega para a tela de perfil
    await Navigator.pushNamed(context, '/my_profile');

    // APÓS O RETORNO (Navigator.pop), recarregue os dados do usuário.
    // O UserSession foi atualizado pela MyProfileForm.
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
      // _profileImageUrl = imageUrl; // Salve a URL da imagem
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Sem Scaffold, pois este é o 'body' do GuardianShell
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header atualizado com a nova função
            GuardianHomeHeader(
              greeting: _greeting,
              userName: _userName,
              imageProfile: _profileImageUrl, // Passe a URL da imagem
              onProfileTap: _navigateToProfile, // Passe a função de callback
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
    );
  }
}