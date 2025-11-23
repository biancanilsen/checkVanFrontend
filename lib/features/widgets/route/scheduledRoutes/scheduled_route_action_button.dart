import 'package:flutter/material.dart';
import '../../../../../../core/theme.dart';

class ScheduledRouteActionButton extends StatelessWidget {
  const ScheduledRouteActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: AppPalette.neutral150,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text('Em breve'),
    );
  }
}