import 'package:check_van_frontend/features/widgets/home/homeGuaridan/next_trip_status/waiting_route_callout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../provider/student_provider.dart';
import './pending_confirmation_callout.dart';
import './track_route_callout.dart';

class NextTripStatus extends StatefulWidget {
  const NextTripStatus({super.key});

  @override
  State<NextTripStatus> createState() => _NextTripStatusState();
}

class _NextTripStatusState extends State<NextTripStatus> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStatus();
    });
  }

  Future<void> _fetchStatus() async {
    await context.read<StudentProvider>().fetchNextTripStatus();
  }

  void _onTrackRoutePressed() {
    print('Navegando para a tela de acompanhamento...');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final isLoading = provider.isStatusLoading;
    final status = provider.tripStatus;

    if (isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (status) {
      case 'EM_ROTA':
        return TrackRouteCallout(onTap: _onTrackRoutePressed);

      case 'AGUARDANDO_OUTROS':
        return const WaitingRouteCallout();

      case 'AGUARDANDO_CONFIRMACAO':
        return const PendingConfirmationCallout();

      case 'NAO_VAI':
      default:
        return const SizedBox.shrink();
    }
  }
}