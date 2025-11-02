// /lib/widgets/team/team_card.dart
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
            // Linha Superior: Título e Ícone de Edição
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
              'Período: $period',
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
                onPressed: onView,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  foregroundColor: AppPalette.primary800,
                  side: BorderSide(color: AppPalette.primary800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  // O padding interno foi removido
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