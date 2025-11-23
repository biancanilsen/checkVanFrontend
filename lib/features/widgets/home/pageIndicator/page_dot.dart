import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class PageDot extends StatelessWidget {
  final bool isActive;

  const PageDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? AppPalette.primary800 : AppPalette.neutral200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}