import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../widgets/custom_text_field.dart';

class SchoolScheduleSection extends StatelessWidget {
  final TextEditingController morningLimitController;
  final TextEditingController morningDepartureController;
  final TextEditingController afternoonLimitController;
  final TextEditingController afternoonDepartureController;
  final Function(TextEditingController) onPickTime;

  const SchoolScheduleSection({
    super.key,
    required this.morningLimitController,
    required this.morningDepartureController,
    required this.afternoonLimitController,
    required this.afternoonDepartureController,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Horários', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPalette.neutral800)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: morningLimitController,
                label: 'Chegada (Manhã)',
                hint: 'HH:mm',
                onTap: () => onPickTime(morningLimitController),
                suffixIcon: Icons.access_time_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: morningDepartureController,
                label: 'Saída (Manhã)',
                hint: 'HH:mm',
                onTap: () => onPickTime(morningDepartureController),
                suffixIcon: Icons.access_time_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: afternoonLimitController,
                label: 'Chegada (Tarde)',
                hint: 'HH:mm',
                onTap: () => onPickTime(afternoonLimitController),
                suffixIcon: Icons.access_time_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: afternoonDepartureController,
                label: 'Saída (Tarde)',
                hint: 'HH:mm',
                onTap: () => onPickTime(afternoonDepartureController),
                suffixIcon: Icons.access_time_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}