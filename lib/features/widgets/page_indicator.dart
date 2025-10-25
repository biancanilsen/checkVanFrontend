import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;

  final int currentIndex;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  Widget _buildDot(int index) {
    bool isActive = index == currentIndex;

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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return _buildDot(index);
      }),
    );
  }
}