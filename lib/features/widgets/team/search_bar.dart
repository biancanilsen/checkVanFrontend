import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchPressed;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.hintText = 'Pesquisar...',
    this.onChanged,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.neutral50, // Cor de fundo do campo de busca
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.neutral200, width: 1), // Borda cinza suave
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppPalette.neutral500,
          ),
          border: InputBorder.none, // Remove a borda padrão do TextField
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: AppPalette.neutral600),
            onPressed: onSearchPressed,
          ),
        ),
      ),
    );
  }
}
