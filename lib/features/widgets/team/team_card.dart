import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class TeamCard extends StatelessWidget {
  final String name;
  final String period;
  final int studentCount;
  final String code;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const TeamCard({
    super.key,
    required this.name,
    required this.period,
    required this.studentCount,
    required this.code,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> shiftOptions = {
      'morning': 'Manhã',
      'afternoon': 'Tarde',
      'night': 'Noite',
    };

    final String displayPeriod = shiftOptions[period] ?? (period.isEmpty ? 'Não informado' : period);

    final bool isEnabled = studentCount > 0;

    return Card(
      color: AppPalette.neutral70,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary900,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: AppPalette.primary800, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Text(
              'Período: $displayPeriod',
              style: TextStyle(color: AppPalette.primary900, fontWeight: FontWeight.w400, fontSize: 14),
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alunos',
                      style: TextStyle(color: AppPalette.primary900, fontWeight: FontWeight.w400, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$studentCount',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary900,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: OutlinedButton(
                onPressed: isEnabled ? onView : null,

                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 44)),

                  foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey.shade500;
                    }
                    return AppPalette.primary800;
                  }),

                  side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return BorderSide(color: Colors.grey.shade300);
                    }
                    return BorderSide(color: AppPalette.primary800);
                  }),

                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),

                child: const Text('Ver turma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}