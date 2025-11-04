import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ConfirmPresenceCallout extends StatelessWidget {
  const ConfirmPresenceCallout({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.yellow200, width: 1.5),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/warning_icon.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              Colors.amber.shade700,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Confirme a presença da rota de amanhã!',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral900,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}