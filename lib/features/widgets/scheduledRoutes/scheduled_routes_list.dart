import 'package:check_van_frontend/core/theme.dart'; // <-- Import que faltava
import 'package:check_van_frontend/features/widgets/ScheduledRoutes/scheduled_route_card.dart';
import 'package:flutter/material.dart';

class ScheduledRoutesList extends StatelessWidget {
  const ScheduledRoutesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        children: [
          ScheduledRouteCard(
            routeName: 'Rota da tarde',
            studentCount: '14',
            startTime: 'Às 11h',
            icon: Icons.brightness_6_outlined,
            chipBgColor: AppPalette.primary50,
            chipTextColor: AppPalette.primary900,
          ),
          const SizedBox(width: 12),
          ScheduledRouteCard(
            routeName: 'Rota da noite',
            studentCount: '9',
            startTime: 'Às 18h',
            icon: Icons.dark_mode_outlined,
            chipBgColor: Colors.purple.shade100,
            chipTextColor: Colors.purple.shade800,
          ),
        ],
      ),
    );
  }
}