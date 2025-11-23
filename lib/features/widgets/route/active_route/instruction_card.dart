import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class InstructionCard extends StatelessWidget {
  final String instruction;
  final bool isSoundOn;
  final VoidCallback onToggleSound;

  const InstructionCard({
    super.key,
    required this.instruction,
    required this.isSoundOn,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.primary800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                instruction,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPalette.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.2),
              child: IconButton(
                icon: Icon(isSoundOn ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                onPressed: onToggleSound,
              ),
            )
          ],
        ),
      ),
    );
  }
}