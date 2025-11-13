import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DeleteStudentDialog extends StatelessWidget {
  final String studentName;
  final VoidCallback onConfirm;
  final bool isLoading;

  const DeleteStudentDialog({
    super.key,
    required this.studentName,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // 1. ADICIONA O RADIUS DE 12
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text('Excluir Aluno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppPalette.primary800),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      content: RichText(
        text: TextSpan(
          // Use o estilo de texto padrão do dialog
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppPalette.neutral700),
          children: <TextSpan>[
            const TextSpan(text: 'Tem certeza que deseja excluir o aluno '),
            TextSpan(
              text: studentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '?'),
          ],
        ),
      ),
      actions: [
        // 2. BOTÃO CANCELAR ATUALIZADO
        OutlinedButton(
          onPressed: isLoading ? null : () => Navigator.pop(context), // Fecha o dialog
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade400), // Borda cinza
            foregroundColor: AppPalette.neutral700, // Cor do texto
          ),
          child: const Text('Cancelar'),
        ),
        // Botão Excluir
        FilledButton(
          onPressed: isLoading ? null : onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.red700,
          ),
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text('Excluir'),
        ),
      ],
    );
  }
}