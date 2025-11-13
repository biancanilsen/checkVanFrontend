import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class DeleteVanDialog extends StatelessWidget {
  final String vanNickname;
  final VoidCallback onConfirm;
  final bool isLoading;

  const DeleteVanDialog({
    super.key,
    required this.vanNickname,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text('Excluir Van', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppPalette.primary800),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      content: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppPalette.neutral700),
          children: <TextSpan>[
            const TextSpan(text: 'Tem certeza que deseja excluir a van '),
            TextSpan(
              text: vanNickname,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '? As turmas associadas a ela serão desvinculadas.'),
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