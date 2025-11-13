import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../enum/snack_bar_type.dart';

class CustomSnackBar {

  static void show({
    required BuildContext context,
    required String label,
    required SnackBarType type,
  }) {
    final Color backgroundColor;
    final Color iconColor;
    final Color textColor;
    final IconData iconData;

    if (type == SnackBarType.success) {
      backgroundColor = AppPalette.green75;
      iconColor = AppPalette.green500;
      textColor = AppPalette.green600;
      iconData = Icons.check_circle;
    } else {
      backgroundColor = AppPalette.red500.withOpacity(0.15);
      iconColor = AppPalette.red500;
      textColor = AppPalette.red700;
      iconData = Icons.error;
    }

    final snackBarContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: iconColor.withOpacity(0.5), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );

    final snackBar = SnackBar(
      content: snackBarContent,

      backgroundColor: Colors.transparent,

      elevation: 0,

      behavior: SnackBarBehavior.floating,

      padding: EdgeInsets.zero,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}