import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:math';

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

  Timer? _modalDelayTimer;
  bool _isCheckingForNoVan = false;

  @override
  void initState() {
    super.initState();

    _createVanIcon().then((icon) {
      if (mounted) {
        setState(() {
          _vanIcon = icon;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VanTrackingProvider>().startTracking(widget.teamId);

      // 1. INICIA O TIMER DE ATRASO APÓS 10 SEGUNDOS
      _startNoVanCheckTimer();
    });
  }

  // MÉTODO DO DRIVER ADAPTADO: Cria uma seta sólida
  Future<BitmapDescriptor> _createVanIcon() async {
    const size = 160.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final iconSize = const Size(size, size);

    final paint = Paint()
      ..color = AppPalette.primary800
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(iconSize.width / 2, 0);
    path.lineTo(iconSize.width, iconSize.height * 0.8);
    path.lineTo(iconSize.width / 2, iconSize.height * 0.6);
    path.lineTo(0, iconSize.height * 0.8);
    path.close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawPath(path, borderPaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(iconSize.width.toInt(), iconSize.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    }
    return BitmapDescriptor.defaultMarker;
  }

  void _startNoVanCheckTimer() {
    if (_isCheckingForNoVan) return;
    _isCheckingForNoVan = true;

    _modalDelayTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted || context.read<VanTrackingProvider>().vanPosition != null) {
        return;
      }

      _showNoVanFoundAlert(context);
    });
  }

  @override
  void dispose() {
    _modalDelayTimer?.cancel();
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

  void _updateVanMarker(LatLng newPosition, double heading) {
    if (!mounted || _mapController == null) return;

    final iconToUse = _vanIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

    _markers.removeWhere((m) => m.markerId.value == 'van_real_time');

    _markers.add(
      Marker(
        markerId: const MarkerId('van_real_time'),
        position: newPosition,
        icon: iconToUse,
        flat: true,
        rotation: heading,
        anchor: const Offset(0.5, 0.5),
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
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.pop(ctx);
          //       Navigator.pop(context);
          //     },
          //     child: const Text("Entendi"),
          //   ),
          // ],
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VanTrackingProvider>();

    _setMarkers();

    if (provider.vanPosition != null) {
      _updateVanMarker(provider.vanPosition!, provider.vanHeading);
      if (_modalDelayTimer?.isActive == true) {
        _modalDelayTimer?.cancel();
      }
    }

    final bool showLoader = provider.isConnecting && provider.vanPosition == null;

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
            markers: _markers,
          ),

          if (showLoader)
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