import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../../../core/theme.dart';
import '../../../../provider/van_tracking_provider.dart';


class GuardianTrackingPage extends StatefulWidget {
  final int teamId;
  final LatLng studentLocation;
  final String teamName;

  const GuardianTrackingPage({
    super.key,
    required this.teamId,
    required this.studentLocation,
    required this.teamName,
  });

  @override
  State<GuardianTrackingPage> createState() => _GuardianTrackingPageState();
}

class _GuardianTrackingPageState extends State<GuardianTrackingPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  bool _hasShownNoVanAlert = false;
  BitmapDescriptor? _vanIcon;
  bool _markersSet = false;

  @override
  void initState() {
    super.initState();

    _loadCustomVanIcon().then((icon) {
      if (mounted) {
        setState(() {
          _vanIcon = icon;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VanTrackingProvider>().startTracking(widget.teamId);
    });
  }

  Future<BitmapDescriptor> _loadCustomVanIcon() async {
    return await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(80, 80)),
        'assets/van.png'
    );
  }

  @override
  void dispose() {
    context.read<VanTrackingProvider>().stopTracking();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _setMarkers() {
    if (_markersSet) return;

    _markers.add(
      Marker(
        markerId: const MarkerId('student_stop'),
        position: widget.studentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Sua Parada'),
        zIndex: 1,
      ),
    );
    _markersSet = true;
    setState(() {});
  }

  void _updateVanMarker(LatLng newPosition) {
    if (!mounted || _mapController == null) return;

    // Usa o ícone customizado após carregamento. Fallback para azul simples se falhar.
    final iconToUse = _vanIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

    _markers.removeWhere((m) => m.markerId.value == 'van_real_time');

    _markers.add(
      Marker(
        markerId: const MarkerId('van_real_time'),
        position: newPosition,
        icon: iconToUse,
        infoWindow: InfoWindow(title: 'Van - ${widget.teamName}'),
        rotation: 0.0,
        zIndex: 2,
      ),
    );

    setState(() {});

    _mapController.animateCamera(
      CameraUpdate.newLatLng(newPosition),
    );
  }

  void _showNoVanFoundAlert(BuildContext context) {
    if (_hasShownNoVanAlert) return;
    _hasShownNoVanAlert = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Van não encontrada"),
          content: Text(
              "A van da turma ${widget.teamName} não está enviando sua localização no momento. Por favor, tente novamente em alguns minutos ou verifique se o motorista iniciou a rota."
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Entendi"),
            ),
          ],
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VanTrackingProvider>();

    _setMarkers();

    if (provider.vanPosition != null) {
      _updateVanMarker(provider.vanPosition!);
    }

    if (!provider.isConnecting && provider.vanPosition == null) {
      _showNoVanFoundAlert(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Acompanhando ${widget.teamName}'),
        backgroundColor: AppPalette.primary800,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.studentLocation,
              zoom: 16,
            ),
            onMapCreated: _onMapCreated,
            // A lista de markers é atualizada via setState de _updateVanMarker
            markers: _markers,
          ),

          if (provider.isConnecting && provider.vanPosition == null)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 12),
                      Text('Conectando ao rastreamento...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}