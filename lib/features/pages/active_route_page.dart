import 'dart:async';
import 'package:check_van_frontend/model/route_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../core/theme.dart';

class ActiveRoutePage extends StatefulWidget {
  const ActiveRoutePage({super.key});

  @override
  State<ActiveRoutePage> createState() => _ActiveRoutePageState();
}

class _ActiveRoutePageState extends State<ActiveRoutePage> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  late GoogleMapController _mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  // Constantes para o controle da câmera de navegação
  static const double _navigationZoom = 18.0;
  static const double _navigationTilt = 45.0;

  @override
  void initState() {
    super.initState();
    _setupLocationListener();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  /// Chamado quando o mapa é criado, inicializa a UI da rota.
  void _onMapCreated(GoogleMapController controller, RouteData routeData) {
    _mapController = controller;
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.complete(controller);
    }
    _setupMapUI(routeData);
  }

  /// Configura os marcadores dos alunos e a linha da rota no mapa.
  void _setupMapUI(RouteData routeData) {
    List<PointLatLng> polylineCoordinates = PolylinePoints().decodePolyline(routeData.encodedPolyline);
    List<LatLng> latLngList = polylineCoordinates.map((p) => LatLng(p.latitude, p.longitude)).toList();

    Polyline routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      color: AppPalette.primary800,
      width: 6,
      points: latLngList,
    );

    setState(() {
      _markers.clear(); // Limpa marcadores de rotas anteriores
      for (var student in routeData.students) {
        _markers.add(
          Marker(
            markerId: MarkerId('student_${student.id}'),
            position: LatLng(student.latitude, student.longitude),
            infoWindow: InfoWindow(title: student.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
      _polylines.add(routePolyline);
    });

    // Move a câmera para focar na rota inteira ao iniciar
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(_boundsFromLatLngList(latLngList), 60.0),
    );
  }

  /// Inicia o rastreamento da localização em tempo real do motorista.
  void _setupLocationListener() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationSubscription = _location.onLocationChanged.listen((LocationData newLocation) {
      if (mounted && newLocation.latitude != null && newLocation.longitude != null) {

        setState(() {
          // Atualiza o marcador da posição do motorista
          _markers.removeWhere((m) => m.markerId.value == 'van_location');
          _markers.add(
            Marker(
              markerId: const MarkerId('van_location'),
              position: LatLng(newLocation.latitude!, newLocation.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              flat: true, // Faz o ícone "deitar" no mapa
              rotation: newLocation.heading ?? 0.0, // Rotaciona o ícone com a direção
              anchor: const Offset(0.5, 0.5), // Centraliza o ícone
            ),
          );
        });

        // Anima a câmera para seguir o motorista com perspectiva de navegação
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(newLocation.latitude!, newLocation.longitude!),
              zoom: _navigationZoom,
              tilt: _navigationTilt,
              bearing: newLocation.heading ?? 0.0, // Orienta o mapa na direção do movimento
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeData = ModalRoute.of(context)!.settings.arguments as RouteData;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Rota Ativa", style: TextStyle(color: AppPalette.primary900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppPalette.primary900),
      ),
      body: Stack(
        children: [
          // O Mapa do Google
          GoogleMap(
            onMapCreated: (controller) => _onMapCreated(controller, routeData),
            initialCameraPosition: CameraPosition(
              target: LatLng(routeData.waypoints.first.lat, routeData.waypoints.first.lon),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // O painel inferior com a lista de paradas
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppPalette.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppPalette.neutral300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        'Próximas paradas',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppPalette.primary900),
                      ),
                    ),
                    // Lista dinâmica de alunos
                    ...routeData.students.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var student = entry.value;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildStopTile(
                          name: student.name,
                          address: student.address,
                          isLastStop: idx == routeData.students.length - 1,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para cada item da lista de paradas
  Widget _buildStopTile({
    required String name,
    required String address,
    required bool isLastStop,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: AppPalette.red700, size: 28),
                if (!isLastStop)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppPalette.neutral300,
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/retratoCrianca.webp'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(address, style: const TextStyle(color: AppPalette.neutral600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função utilitária para calcular os limites da rota
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }
}

