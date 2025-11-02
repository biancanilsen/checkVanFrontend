import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class GuardianHomeHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final String? imageProfile;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap; // 1. ADICIONE O NOVO CALLBACK

  const GuardianHomeHeader({
    super.key,
    required this.greeting,
    required this.userName,
    this.imageProfile,
    required this.onProfileTap,
    required this.onLogoutTap, // 2. ADICIONE AO CONSTRUTOR
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Texto de saudação
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppPalette.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
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

        // 3. ADICIONE O BOTÃO DE LOGOUT AQUI
        IconButton(
          icon: Icon(Icons.logout, color: Colors.grey[700]),
          onPressed: onLogoutTap, // Chama o callback
          tooltip: 'Sair', // Texto de acessibilidade
        ),

        // Mantém um pequeno espaço
        const SizedBox(width: 8),

        // Avatar de Perfil
        GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 24,
            backgroundImage: (imageProfile != null && imageProfile!.isNotEmpty)
                ? NetworkImage(imageProfile!)
                : const AssetImage('assets/profile.png') as ImageProvider,
          ),
        ),
      ],
    );
  }
}