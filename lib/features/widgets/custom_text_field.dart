import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final bool readOnly;

  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSuffixIconTap;

  final TextCapitalization textCapitalization;

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
    this.readOnly = false,

    this.obscureText = false,
    this.onChanged,
    this.onSuffixIconTap,
    this.textCapitalization = TextCapitalization.sentences,
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
              fontSize: 14,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppPalette.red700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          readOnly: (onTap != null) || readOnly,
          onTap: readOnly ? null : onTap,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,

          textCapitalization: obscureText ? TextCapitalization.none : textCapitalization,

          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: hint,
            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
            suffixIcon: suffixIcon != null
                ? IconButton(
              icon: Icon(suffixIcon, color: AppPalette.neutral600),
              onPressed: onSuffixIconTap,
            )
                : null,
          ),
        ),
      ],
    );
  }
}