import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class ResetPasswordHeader extends StatelessWidget {
  const ResetPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFEBF2F7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 40,
            color: AppPalette.primary800,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Criar Nova Senha",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppPalette.primary800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sua nova senha deve ser diferente das senhas anteriores",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppPalette.neutral700, fontSize: 16),
        ),
      ],
    );
  }
}