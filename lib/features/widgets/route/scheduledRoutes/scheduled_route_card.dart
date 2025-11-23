import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/features/widgets/route/scheduledRoutes/route_info_item.dart';
import 'package:check_van_frontend/features/widgets/route/scheduledRoutes/scheduled_route_action_button.dart';
import 'package:check_van_frontend/features/widgets/route/scheduledRoutes/scheduled_route_header.dart';
import 'package:flutter/material.dart';

class ScheduledRouteCard extends StatelessWidget {
  final String routeName;
  final String studentCount;
  final String startTime;
  final IconData icon;
  final Color chipBgColor;
  final Color chipTextColor;

  const ScheduledRouteCard({
    super.key,
    required this.routeName,
    required this.studentCount,
    required this.startTime,
    required this.icon,
    required this.chipBgColor,
    required this.chipTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.80,
      child: Card(
        color: AppPalette.neutral50,
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduledRouteHeader(
                icon: icon,
                routeName: routeName,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteInfoItem(
                    label: 'Alunos',
                    value: studentCount,
                    boldValue: true,
                  ),
                  RouteInfoItem(
                    label: 'Início',
                    value: '',
                    isChip: true,
                    chipLabel: startTime,
                    chipBgColor: AppPalette.primary50,
                    chipTextColor: AppPalette.primary900,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const ScheduledRouteActionButton(),
            ],
          ),
        ),
      ),
    );
  }
}