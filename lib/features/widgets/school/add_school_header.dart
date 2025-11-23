import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AddSchoolHeader extends StatelessWidget {
  final bool isEditing;

  const AddSchoolHeader({super.key, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isEditing ? 'Editar Escola' : 'Dados da Escola',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppPalette.primary800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEditing
              ? 'Atualize as informações da escola.'
              : 'Preencha as informações para cadastrar uma nova escola.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppPalette.neutral600),
        ),
      ],
    );
  }
}