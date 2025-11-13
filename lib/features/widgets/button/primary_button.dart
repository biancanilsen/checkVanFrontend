import 'package:flutter/material.dart';
import '../../../core/theme.dart'; // Mantendo o import, embora usaremos Colors.grey

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Pega o estilo de botão do tema global (que tem o radius de 34px)
    final themeStyle = Theme.of(context).elevatedButtonTheme.style;

    // Faz uma cópia (copyWith) do estilo do tema,
    // mas sobrescrevendo TODAS as propriedades que queremos
    final localStyle = themeStyle?.copyWith(
      backgroundColor: MaterialStateProperty.all(Colors.grey.shade200),
      foregroundColor: MaterialStateProperty.all(Colors.black87),
      elevation: MaterialStateProperty.all(0),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 16),
      ),
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      // AQUI: Força a sobrescrita do shape para 8px
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      // Aplica o novo estilo mesclado e sobrescrito
      style: localStyle,
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          // Altera a cor do loading para combinar com o texto
          color: Colors.black87,
          strokeWidth: 2,
        ),
      )
          : Text(text),
    );
  }
}