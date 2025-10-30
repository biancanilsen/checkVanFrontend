import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/features/widgets/team/period_selector.dart'; // Para o enum Period
import 'package:flutter/material.dart';

import '../../../model/team_model.dart';

class TeamListTile extends StatelessWidget {
  final Team team;
  final VoidCallback onEdit;
  final VoidCallback onViewTeam;

  const TeamListTile({
    super.key,
    required this.team,
    required this.onEdit,
    required this.onViewTeam,
  });

  String _periodToDisplayString(Period period) {
    switch (period) {
      case Period.morning:
        return 'manhã';
      case Period.afternoon:
        return 'tarde';
      case Period.night:
        return 'noite';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1, // Leve sombra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  team.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppPalette.primary900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppPalette.neutral600),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Período: ${_periodToDisplayString(team.period)}',
              style: textTheme.bodyMedium?.copyWith(
                color: AppPalette.neutral600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alunos',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalette.neutral500,
                      ),
                    ),
                    Text(
                      team.studentCount.toString(),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.neutral800,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Código',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalette.neutral500,
                      ),
                    ),
                    Text(
                      team.code,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.neutral800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewTeam,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPalette.primary800,
                  side: const BorderSide(color: AppPalette.primary800),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                child: const Text('Ver turma'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
