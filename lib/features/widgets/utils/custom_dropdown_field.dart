// /lib/widgets/utils/custom_dropdown_field.dart
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool readOnly;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            children: [
              TextSpan(text: label),
              const TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(hint, style: Theme.of(context).inputDecorationTheme.hintStyle),
          decoration: const InputDecoration(),
          borderRadius: BorderRadius.circular(12.0),
          items: items,
          onChanged: readOnly ? null : onChanged,
          validator: validator,
        ),
      ],
    );
  }
}