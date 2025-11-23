import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';

class WeekSelectorDayCard extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final String? status;
  final VoidCallback onTap;

  const WeekSelectorDayCard({
    super.key,
    required this.day,
    required this.isSelected,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat.E('pt_BR').format(day);
    final dayAbbreviation = '${dayFormat[0].toUpperCase()}${dayFormat.substring(1)}';
    final dayNumber = DateFormat.d('pt_BR').format(day);

    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'BOTH':
      case 'GOING':
      case 'RETURNING':
        iconData = Icons.check_circle_outline;
        iconColor = AppPalette.green600;
        break;
      case 'NONE':
        iconData = Icons.cancel_outlined;
        iconColor = AppPalette.red700;
        break;
      case null:
      default:
        iconData = Icons.watch_later_outlined;
        iconColor = AppPalette.orange700;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppPalette.green600, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          children: [
            Text(
              dayAbbreviation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.green600 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.green600 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              iconData,
              color: iconColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}