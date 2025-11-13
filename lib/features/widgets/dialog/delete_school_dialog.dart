import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DeleteSchoolDialog extends StatelessWidget {
  final String schoolName;
  final VoidCallback onConfirm;
  final bool isLoading;

  const DeleteSchoolDialog({
    super.key,
    required this.schoolName,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Usa o shape global (ou local de 12)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text('Excluir Escola', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppPalette.primary800),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      content: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppPalette.neutral700),
          children: <TextSpan>[
            const TextSpan(text: 'Tem certeza que deseja excluir a escola '),
            TextSpan(
              text: schoolName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '?'),
          ],
        ),
      ),
      actions: [
        // Botão Cancelar
        OutlinedButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade400),
            foregroundColor: AppPalette.neutral700,
          ),
          child: const Text('Cancelar'),
        ),
        // Botão Excluir
        FilledButton(
          onPressed: isLoading ? null : onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.red500,
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