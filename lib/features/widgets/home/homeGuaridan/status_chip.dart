import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color border;
  final Color text;

  const StatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.border,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}