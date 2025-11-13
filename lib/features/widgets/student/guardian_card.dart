import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme.dart';

class GuardianCard extends StatelessWidget {
  final String name;
  final String? phone;
  final VoidCallback? onCallPressed;
  final VoidCallback? onChatPressed;

  const GuardianCard({
    super.key,
    required this.name,
    this.phone,
    this.onCallPressed,
    this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
    side: BorderSide(
    color: AppPalette.primary100,
    width: 2.0,
    ),
    ),
      color: AppPalette.neutral70, // Cor de fundo do card
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nome',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppPalette.primary900,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Telefone',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    phone ?? 'Não cadastrado',
                    style: const TextStyle(
                      color: AppPalette.primary900,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone_outlined, color: AppPalette.primary800, size: 24),
                  onPressed: onCallPressed,
                ),
                const SizedBox(height: 12),

                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppPalette.green500, size: 24),
                  onPressed: onChatPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}