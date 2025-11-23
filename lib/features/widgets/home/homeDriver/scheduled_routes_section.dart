import 'package:flutter/material.dart';
import '../../../../provider/tripProvider.dart';
import '../../route/scheduledRoutes/scheduled_routes_list.dart';

class ScheduledRoutesSection extends StatelessWidget {
  final TripProvider provider;

  const ScheduledRoutesSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading || provider.error != null) {
      return const SizedBox.shrink();
    }

    return ScheduledRoutesList(
      scheduledTrips: provider.scheduledTrips,
    );
  }
}