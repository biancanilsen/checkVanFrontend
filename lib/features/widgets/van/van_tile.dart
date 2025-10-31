import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class VanTile extends StatelessWidget {
  final String name;
  final String model;
  final String plate;
  final VoidCallback onTap;

  const VanTile({
    super.key,
    required this.name,
    required this.model,
    required this.plate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.airport_shuttle_outlined, color: Colors.grey[700]),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppPalette.primary900),
      ),
      subtitle: Text(
        "$model\nPlaca: $plate", // O subtítulo de duas linhas
        style: TextStyle(color: Colors.grey[700]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
      onTap: onTap,
      // A propriedade 'isThreeLine: true' foi removida
      // para permitir o centramento vertical padrão.
    );
  }
}