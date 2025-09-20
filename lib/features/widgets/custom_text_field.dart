import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importe para usar TextInputFormatter
import '../../core/theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isRequired;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final IconData? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isRequired = false,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.suffixIcon,
    this.inputFormatters,
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
                    color: AppPalette.red500,
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
          inputFormatters: inputFormatters, // Propriedade passada para o TextFormField
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppPalette.neutral600) : null,
          ),
        ),
      ],
    );
  }
}

