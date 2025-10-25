import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class RoutePageHeader extends StatelessWidget {
  final bool isLoading;
  final String? userName;
  final String routeName;

  const RoutePageHeader({
    super.key,
    required this.isLoading,
    this.userName,
    this.routeName = 'Rota da manhã', // Você pode passar isso como parâmetro
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(
            'Olá, ${userName ?? 'Motorista'}!',
            style:
            const TextStyle(fontSize: 18, color: AppPalette.neutral600),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            routeName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppPalette.primary900,
            ),
          ),
        ),
      ],
    );
  }
}