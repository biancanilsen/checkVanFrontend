import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class ScheduledRouteCard extends StatelessWidget {
  final String routeName;
  final String studentCount;
  final String startTime;
  final IconData icon;
  final Color chipBgColor;
  final Color chipTextColor;

  const ScheduledRouteCard({
    super.key,
    required this.routeName,
    required this.studentCount,
    required this.startTime,
    required this.icon,
    required this.chipBgColor,
    required this.chipTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.80,
      child: Card(
        color: AppPalette.neutral50,
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Faz o Row encolher
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      routeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRouteInfoColumn(
                    'Alunos',
                    studentCount,
                    boldValue: true,
                  ),
                  _buildRouteInfoColumn(
                    'Início',
                    '',
                    isChip: true,
                    chipLabel: startTime,
                    chipBgColor: AppPalette.primary50,
                    chipTextColor: AppPalette.primary900,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: null, // Botão desabilitado
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppPalette.neutral150,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Em breve',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget helper que foi movido junto com o card
  Widget _buildRouteInfoColumn(
      String label,
      String value, {
        bool boldValue = false,
        IconData? icon,
        bool isChip = false,
        String chipLabel = '',
        Color? chipBgColor,
        Color? chipTextColor,
      }) {
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
              style:
              TextStyle(color: chipTextColor, fontWeight: FontWeight.w600),
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