import 'package:flutter/material.dart';

class ScheduledRouteHeader extends StatelessWidget {
  final IconData icon;
  final String routeName;

  const ScheduledRouteHeader({
    super.key,
    required this.icon,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            routeName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}