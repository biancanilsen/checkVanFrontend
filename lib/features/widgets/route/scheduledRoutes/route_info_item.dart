import 'package:flutter/material.dart';

class RouteInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool boldValue;
  final IconData? icon;
  final bool isChip;
  final String chipLabel;
  final Color? chipBgColor;
  final Color? chipTextColor;

  const RouteInfoItem({
    super.key,
    required this.label,
    required this.value,
    this.boldValue = false,
    this.icon,
    this.isChip = false,
    this.chipLabel = '',
    this.chipBgColor,
    this.chipTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (isChip)
          Chip(
            label: Text(
              chipLabel,
              style: TextStyle(color: chipTextColor, fontWeight: FontWeight.w600),
            ),
            backgroundColor: chipBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
            side: BorderSide.none,
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: boldValue ? 20 : 24,
              fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }
}