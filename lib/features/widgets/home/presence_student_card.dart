import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'status_chip.dart'; 

class PresenceStudentCard extends StatelessWidget {
  final String name;
  final bool isConfirmed;
  final VoidCallback? onTap;
  final String? imageUrl;

  const PresenceStudentCard({
    super.key,
    required this.name,
    required this.isConfirmed,
    this.onTap,
    this.imageUrl,
  });

  // A lógica de logout foi mantida aqui como no seu original
  void _logout(BuildContext context) async {
    await UserSession.signOutUser();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

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
              GestureDetector(
                onTap: () => _logout(context), // Mantido do seu código
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? NetworkImage(imageUrl!)
                      : const AssetImage('assets/profile.png') as ImageProvider,
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
                    isConfirmed
                        ? const StatusChip(
                      label: 'Confirmado',
                      background: Color(0xFFE4F8F0),
                      border: Color(0xFF66DDAA),
                      text: Color(0xFF006B3F),
                    )
                        : const StatusChip(
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
                color:
                onTap == null ? AppPalette.neutral300 : AppPalette.neutral600,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}