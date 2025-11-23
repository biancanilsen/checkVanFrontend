import 'package:flutter/material.dart';
import '../../../../provider/tripProvider.dart';
import '../../route/nextRoute/next_route_card.dart';

class NextRouteSection extends StatelessWidget {
  final TripProvider provider;

  const NextRouteSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(child: Text('Erro: ${provider.error}')),
      );
    }

    return NextRouteCard(
      nextTrip: provider.nextTrip,
    );
  }
}