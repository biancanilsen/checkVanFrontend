import 'package:check_van_frontend/features/widgets/home/homeGuaridan/next_trip_status/no_student_callout.dart';
import 'package:check_van_frontend/features/widgets/home/homeGuaridan/next_trip_status/waiting_route_callout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../provider/student_provider.dart';
import '../../../../pages/route/tracking/guardian_tracking_page.dart';
import './pending_confirmation_callout.dart';
import './track_route_callout.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importe LatLng

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

  void _onTrackRoutePressed(int teamId, LatLng studentLocation, String teamName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuardianTrackingPage(
          teamId: teamId,
          studentLocation: studentLocation,
          teamName: teamName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final isLoading = provider.isStatusLoading;
    final status = provider.tripStatus;

    final activeTripData = provider.getActiveTripDetails();

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
        if (activeTripData != null &&
            activeTripData.studentLocation != null &&
            activeTripData.teamId != null &&
            activeTripData.teamName != null)
        {
          return TrackRouteCallout(
            onTap: () => _onTrackRoutePressed(
              activeTripData.teamId!,
              activeTripData.studentLocation!,
              activeTripData.teamName!,
            ),
          );
        }
        // Fallback: Se o status é EM_ROTA mas os dados da van não vieram (erro na API), mostramos waiting.
        return const WaitingRouteCallout();

      case 'AGUARDANDO_OUTROS':
        return const WaitingRouteCallout();

      case 'AGUARDANDO_CONFIRMACAO':
        return const PendingConfirmationCallout();

      case 'SEM_ALUNO':
        return const NoStudentCallout();

      case 'NAO_VAI':
      default:
      // Retorna um SizedBox vazio se não houver status relevante
        return const SizedBox.shrink();
    }
  }
}