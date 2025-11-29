import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PendingConfirmationCallout extends StatelessWidget {
  const PendingConfirmationCallout({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    final message = isWeekend
        ? 'Confirme a presença da rota de segunda-feira!'
        : 'Confirme a presença da rota de amanhã!';

    return Column(
      children: [
        Image.asset(
          'assets/school_bus.png',
          height: 200,
          width: double.infinity,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppPalette.yellow200,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/warning_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppPalette.yellow200,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppPalette.neutral900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}