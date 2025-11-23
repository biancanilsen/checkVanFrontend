import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class PasswordRequirementsList extends StatelessWidget {
  final String password;

  const PasswordRequirementsList({
    super.key,
    required this.password,
  });

  // Regras baseadas no NIST SP 800-63B
  // 1. Mínimo recomendado hoje é 10 ou 12 caracteres.
  // 2. Passphrases (frases) são mais seguras que senhas curtas e complexas.
  bool get _hasMinLength => password.length >= 10;
  bool get _isStrongLength => password.length >= 15;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Força da senha",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppPalette.primary800),
          ),
          const SizedBox(height: 8),
          const Text(
            "Dica: Use uma frase longa e fácil de lembrar. Não é necessário usar símbolos ou maiúsculas obrigatórias.",
            style: TextStyle(fontSize: 13, color: AppPalette.neutral700),
          ),
          const SizedBox(height: 16),

          // Barra de Progresso Visual
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (password.length / 15).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
            ),
          ),
          const SizedBox(height: 16),

          // Requisito Obrigatório
          _buildRequirement(
            "Mínimo de 10 caracteres",
            _hasMinLength,
            isMandatory: true,
          ),

          // Incentivo (Opcional)
          _buildRequirement(
            "Ótimo: 15+ caracteres (frase-senha)",
            _isStrongLength,
            isMandatory: false,
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor() {
    if (password.length < 8) return AppPalette.red500; // Muito fraca
    if (password.length < 10) return AppPalette.orange700; // Fraca
    if (password.length < 15) return AppPalette.primary800; // Boa
    return AppPalette.green600; // Excelente
  }

  Widget _buildRequirement(String text, bool met, {required bool isMandatory}) {
    final color = met
        ? AppPalette.green600
        : (isMandatory ? AppPalette.neutral600 : AppPalette.neutral500);

    final icon = met
        ? Icons.check_circle
        : (isMandatory ? Icons.circle_outlined : Icons.add_circle_outline);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: met ? AppPalette.primary900 : AppPalette.neutral700,
                fontSize: 13,
                fontWeight: met ? FontWeight.w600 : FontWeight.normal,
                decoration: (met && !isMandatory) ? null : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}