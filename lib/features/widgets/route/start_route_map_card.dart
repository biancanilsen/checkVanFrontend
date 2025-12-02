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
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/rota.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStartRoutePressed,
                    style: buttonStyle,
                    child: const Text('Iniciar rota'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}