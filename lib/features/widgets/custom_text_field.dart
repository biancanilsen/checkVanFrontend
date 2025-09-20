import 'package:flutter/material.dart';
import '../../core/theme.dart'; // Importe sua paleta de cores

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isRequired;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isRequired = false,
    this.suffixIcon,
    this.onTap,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppPalette.red500, // Cor vermelha para o asterisco
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppPalette.neutral600) : null,
          ),
        ),
      ],
    );
  }
}