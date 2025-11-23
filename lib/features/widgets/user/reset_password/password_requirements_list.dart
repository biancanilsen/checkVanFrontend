import 'package:flutter/material.dart';

class PasswordRequirementsList extends StatelessWidget {
  final bool has8Chars;
  final bool hasUpper;
  final bool hasLower;
  final bool hasNumber;
  final bool hasSpecial;

  const PasswordRequirementsList({
    super.key,
    required this.has8Chars,
    required this.hasUpper,
    required this.hasLower,
    required this.hasNumber,
    required this.hasSpecial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sua senha deve conter:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildRequirement("Mínimo de 8 caracteres", has8Chars),
          _buildRequirement("Pelo menos uma letra maiúscula", hasUpper),
          _buildRequirement("Pelo menos uma letra minúscula", hasLower),
          _buildRequirement("Pelo menos um número", hasNumber),
          _buildRequirement("Pelo menos um caractere especial (!@#\$%...)", hasSpecial),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            color: met ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: met ? Colors.green : Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}