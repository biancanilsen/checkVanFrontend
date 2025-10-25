import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class StartRouteMapCard extends StatelessWidget {
  final VoidCallback onStartRoutePressed;

  const StartRouteMapCard({
    super.key,
    required this.onStartRoutePressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppPalette.primary800,
      foregroundColor: AppPalette.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Column(
        children: [
          Image.asset(
            'assets/rota.png',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartRoutePressed, // Usa o callback
                style: buttonStyle,
                child: const Text('Iniciar rota'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}