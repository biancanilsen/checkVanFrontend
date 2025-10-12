import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/features/pages/confirm_attendance_page.dart';

import '../../provider/student_provider.dart';
import '../../provider/route_provider.dart';
import '../../utils/user_session.dart';
import '../widgets/home_route_card.dart';

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
    final greeting = hour < 12 ? 'Bom dia,' : hour < 18 ? 'Boa tarde,' : 'Boa noite,';
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppPalette.neutral900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineMedium?.copyWith(
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.neutral900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/retratoCrianca.webp',
                        fit: BoxFit.cover,
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ),
                ],
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

              // Yellow "Confirm" callout
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.secondary500, width: 1.5),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/warning_icon.svg', // <-- Use o caminho do seu SVG
                      width: 24, // Ajuste o tamanho conforme a necessidade
                      height: 24, // Ajuste o tamanho conforme a necessidade
                      colorFilter: ColorFilter.mode(
                        Colors.amber.shade700, // <-- Mantém a cor original
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Confirme a presença da rota de amanhã!',
                        // MUDANÇA AQUI: Usa o tema
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppPalette.neutral900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Confirmação de presença',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppPalette.neutral900,
                ),
              ),
              const SizedBox(height: 12),

              // Students list (Consumer)
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
                        // MUDANÇA AQUI: Usa o tema
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
                        // MUDANÇA AQUI: Usa o tema
                        style: textTheme.bodyMedium,
                      ),
                    );
                  }

                  // O map para _PresenceStudentCard permanece igual
                  return Column(
                    children: students.map(
                          (s) => _PresenceStudentCard(
                        name: s.name,
                        // NOVO: Passe o status de confirmação para o card
                        isConfirmed: s.isPresenceConfirmed,
                        // NOVO: Desabilite o clique se já estiver confirmado
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmAttendancePage(
                                studentId: s.id,
                                studentName: s.name,
                                studentImageUrl: 'assets/retratoCrianca.webp',
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

// Widget _PresenceStudentCard corrigido
class _PresenceStudentCard extends StatelessWidget {
  final String name;
  final bool isConfirmed;
  final VoidCallback? onTap;

  const _PresenceStudentCard({
    required this.name,
    required this.isConfirmed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: AppPalette.neutral50,
      elevation: 0.6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: ClipOval( // Corrigido para ClipOval para avatares
                  child: Image.asset(
                    'assets/retratoCrianca.webp',
                    height: 70, // Corrigido tamanho
                    width: 70, // Corrigido tamanho
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppPalette.neutral900,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),
                    // LÓGICA DO STATUS CHIP ATUALIZADA
                    isConfirmed
                        ? const _StatusChip(
                      label: 'Confirmado',
                      background: Color(0xFFE4F8F0),
                      border: Color(0xFF66DDAA),
                      text: Color(0xFF006B3F),
                    )
                        : const _StatusChip(
                      label: 'Pendente',
                      background: Color(0xFFFFF1E0),
                      border: Color(0xFFFFC48A),
                      text: Color(0xFFB86100),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                // Torna o ícone mais claro se o card estiver desabilitado
                color: onTap == null ? AppPalette.neutral300 : AppPalette.neutral600,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget _StatusChip corrigido
class _StatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color border;
  final Color text;

  const _StatusChip({
    required this.label,
    required this.background,
    required this.border,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // Pegue o textTheme aqui também
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        // MUDANÇA AQUI: Usa o tema
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}