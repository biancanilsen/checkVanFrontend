import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DangerOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const DangerOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.red500, // Cor do texto
        side: const BorderSide(color: AppPalette.red500, width: 2), // Cor da borda
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: AppPalette.red500,
          strokeWidth: 2,
        ),
      )
          : Text(text),
    );
  }
}