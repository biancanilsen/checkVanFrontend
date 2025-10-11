import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:check_van_frontend/model/route_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  // --- Variáveis para Navegação por Voz ---
  final FlutterTts _flutterTts = FlutterTts();
  late final RouteData _routeData;
  int _currentStepIndex = 0;
  String _currentInstruction = "Iniciando a rota...";
  bool _isDisposed = false;
  bool _isSoundOn = true; // Novo: controla o estado do som

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  // Constantes para o controle da câmera
  static const double _navigationZoom = 18.0;
  static const double _navigationTilt = 45.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)!.settings.arguments is RouteData) {
        _routeData = ModalRoute.of(context)!.settings.arguments as RouteData;
        if (_routeData.steps.isNotEmpty) {
          _currentInstruction = _routeData.steps.first.instruction;
        }
        _initializeTts();
        _setupLocationListener();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationSubscription?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  /// Inicializa o motor de Text-to-Speech e fala a primeira instrução.
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    if (_routeData.steps.isNotEmpty) {
      _speakInstruction(_routeData.steps.first.instruction);
    }
  }

  /// Converte um texto em voz, SE o som estiver ativado.
  void _speakInstruction(String text) {
    if (_isDisposed || !_isSoundOn) return; // Não fala se o som estiver desligado
    // Limpa tags HTML que podem vir da API do Google
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    _flutterTts.speak(cleanText);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.complete(controller);
    }
    _setupMapUI(_routeData);
  }

  /// Desenha a rota e os marcadores no mapa.
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
      _markers.clear();
      for (var student in routeData.students) {
        if(student.latitude != null && student.longitude != null){
          _markers.add(
            Marker(
              markerId: MarkerId('student_${student.id}'),
              position: LatLng(student.latitude!, student.longitude!),
              infoWindow: InfoWindow(title: student.name),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );
        }
      }
      _polylines.add(routePolyline);
    });
    if (latLngList.isNotEmpty) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFromLatLngList(latLngList), 60.0),
      );
    }
  }

  /// Inicia o listener de localização e implementa a lógica de navegação.
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
      if (_isDisposed || newLocation.latitude == null || newLocation.longitude == null) return;

      final currentPosition = LatLng(newLocation.latitude!, newLocation.longitude!);

      setState(() {
        _markers.removeWhere((m) => m.markerId.value == 'van_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('van_location'),
            position: currentPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            flat: true, // "Deita" o ícone no mapa para permitir rotação
            rotation: newLocation.heading ?? 0.0, // Rotaciona o ícone com a direção do celular
            anchor: const Offset(0.5, 0.5), // Centraliza o ícone
          ),
        );
      });

      // Anima a câmera para uma visão de navegação 3D
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentPosition,
            zoom: _navigationZoom,
            tilt: _navigationTilt, // Inclina a câmera
            bearing: newLocation.heading ?? 0.0, // Gira o mapa para corresponder à direção
          ),
        ),
      );

      // Lógica para as instruções de voz
      if (_currentStepIndex < _routeData.steps.length - 1) {
        final nextManeuverPosition = _routeData.steps[_currentStepIndex].endLocation;
        final distanceToManeuver = _calculateDistance(
          currentPosition.latitude, currentPosition.longitude,
          nextManeuverPosition.latitude, nextManeuverPosition.longitude,
        );

        if (distanceToManeuver < 130) { // Fala a próxima instrução a 50m da manobra
          _currentStepIndex++;
          final nextInstruction = _routeData.steps[_currentStepIndex].instruction;
          setState(() => _currentInstruction = nextInstruction);
          _speakInstruction(nextInstruction);
        }
      }
    });
  }

  // Função para calcular a distância em metros entre duas coordenadas (Haversine)
  double _calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  @override
  Widget build(BuildContext context) {
    final routeData = ModalRoute.of(context)?.settings.arguments;
    if (routeData == null || routeData is! RouteData) {
      return const Scaffold(body: Center(child: Text("Dados da rota não encontrados.")));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(routeData.students.first.latitude ?? 0.0, routeData.students.first.longitude ?? 0.0),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false, // Remove a bússola padrão, pois o mapa já gira
          ),

          // Card de instrução no topo com o botão de som
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Card(
              color: AppPalette.primary800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentInstruction,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPalette.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botão para ativar/desativar o som
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: IconButton(
                        icon: Icon(_isSoundOn ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isSoundOn = !_isSoundOn;
                            if (!_isSoundOn) {
                              _flutterTts.stop(); // Para a fala atual se o som for desativado
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: routeData.students.length,
                        itemBuilder: (context, index) {
                          final student = routeData.students[index];
                          // Adiciona um padding para o espaçamento vertical
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: _buildStopTile(
                              name: student.name,
                              address: student.address ?? 'Endereço não informado',
                              isLastStop: index == routeData.students.length - 1,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para cada item da lista de paradas (ATUALIZADO)
  Widget _buildStopTile({
    required String name,
    required String address,
    required bool isLastStop,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A "Linha do Tempo" com o pino e a linha vertical
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
          // Avatar e informações do aluno
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

