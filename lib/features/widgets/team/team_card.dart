// /lib/widgets/team/team_card.dart
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class TeamCard extends StatelessWidget {
  final String name;
  final String period;
  final int studentCount;
  final String code;
  final VoidCallback onEdit; // 1. Adicione
  final VoidCallback onView; // 2. Adicione

  const TeamCard({
    super.key,
    required this.name,
    required this.period,
    required this.studentCount,
    required this.code,
    required this.onEdit, // 3. Adicione
    required this.onView, // 4. Adicione
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // ... (seu Card)
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, /* ... */),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: AppPalette.primary800, size: 20),
                  onPressed: onEdit, // 5. Use o callback
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // ... (resto do seu layout)
            Row(
              // ...
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onView, // 6. Use o callback
              style: OutlinedButton.styleFrom(
                // ... (estilo)
              ),
              child: const Text('Ver turma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}