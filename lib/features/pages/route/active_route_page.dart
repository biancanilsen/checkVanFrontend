import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import 'package:check_van_frontend/model/route_model.dart';
import 'package:check_van_frontend/model/student_model.dart';
import 'package:check_van_frontend/provider/notification_provider.dart';
import '../../../core/theme.dart';
import '../../../enum/snack_bar_type.dart';
import '../../widgets/van/custom_snackbar.dart';

class ActiveRoutePage extends StatefulWidget {
  const ActiveRoutePage({super.key});

  @override
  State<ActiveRoutePage> createState() => _ActiveRoutePageState();
}

class _ActiveRoutePageState extends State<ActiveRoutePage> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  late GoogleMapController _mapController;
  final _sheetController = DraggableScrollableController();
  final Location _location = Location();
  final FlutterTts _flutterTts = FlutterTts();
  StreamSubscription<LocationData>? _locationSubscription;
  Timer? _etaUpdateTimer;

  late final RouteData _routeData;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LocationData? _lastLocation;
  BitmapDescriptor? _navigationIcon;

  int _currentStopIndex = 0;
  bool _hasArrivedAtStop = false;
  bool _isRouteFinished = false;
  bool _isBoarding = false;
  bool _firstNotificationSent = false;

  String _schoolEtaText = "-- min";
  String? _nextStopEtaText;

  double _sheetPosition = 0.4;
  bool _isCameraCentered = true;
  bool _isSoundOn = true;
  String _currentInstruction = "Iniciando a rota...";
  int _currentStepIndex = 0;
  bool _isDisposed = false;
  bool _isProgrammaticMovement = false;

  static const double _arrivalThreshold = 100.0;
  static const double _navigationZoom = 18.0;
  static const double _navigationTilt = 45.0;
  static const double _averageSpeedKmh = 25.0;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);

    _createNavigationIcon().then((icon) {
      if (mounted) setState(() => _navigationIcon = icon);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)!.settings.arguments is RouteData) {
        _routeData = ModalRoute.of(context)!.settings.arguments as RouteData;
        if (_routeData.steps.isNotEmpty) {
          _currentInstruction = _routeData.steps.first.instruction;
        }
        _initializeTts();
        _setupLocationListener();

        if (!_firstNotificationSent && _routeData.students.isNotEmpty) {
          _refreshEtas(sendNotification: true);
          _firstNotificationSent = true;
        }

        _startEtaTimer();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _etaUpdateTimer?.cancel();
    _locationSubscription?.cancel();
    _flutterTts.stop();
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    setState(() {
      _sheetPosition = _sheetController.size;
    });
  }

  void _startEtaTimer() {
    _etaUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!_isRouteFinished && !_isDisposed) {
        _refreshEtas(sendNotification: false);
      }
    });
  }

  int _calculateLocalEta(LatLng from, LatLng to) {
    if ((from.latitude.abs() < 0.0001 && from.longitude.abs() < 0.0001) ||
        (to.latitude.abs() < 0.0001 && to.longitude.abs() < 0.0001)) {
      return 0;
    }
    double distMeters = _calculateDistance(from.latitude, from.longitude, to.latitude, to.longitude);
    double speedMetersPerMin = (_averageSpeedKmh * 1000) / 60;
    double minutes = distMeters / speedMetersPerMin;
    return minutes.ceil() + 2;
  }

  Future<void> _refreshEtas({required bool sendNotification}) async {
    LatLng? startPoint;
    if (_lastLocation != null && _lastLocation!.latitude != null) {
      startPoint = LatLng(_lastLocation!.latitude!, _lastLocation!.longitude!);
    } else {
      try {
        final currentLocation = await _location.getLocation().timeout(const Duration(seconds: 2));
        if (currentLocation.latitude != null) {
          _lastLocation = currentLocation;
          startPoint = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        }
      } catch (e) {}
    }

    if (startPoint == null) {
      if (_currentStopIndex > 0 && _currentStopIndex < _routeData.students.length) {
        final prev = _routeData.students[_currentStopIndex - 1];
        if (prev.latitude != null) startPoint = LatLng(prev.latitude!, prev.longitude!);
      } else {
        if (_routeData.schoolLocation.latitude.abs() > 0.0001) {
          startPoint = _routeData.schoolLocation;
        }
      }
    }

    if (startPoint == null) return;

    final provider = context.read<NotificationProvider>();

    List<int> remainingIds = [];
    if (_currentStopIndex < _routeData.students.length) {
      for (int i = _currentStopIndex; i < _routeData.students.length; i++) {
        remainingIds.add(_routeData.students[i].id);
      }
    }

    final result = await provider.calculateRouteEtas(
        currentLat: startPoint.latitude,
        currentLon: startPoint.longitude,
        remainingStudentIds: remainingIds,
        teamId: _routeData.teamId
    );

    int nextStopMinutes = 0;
    int totalSchoolMinutes = 0;

    if (result != null) {
      nextStopMinutes = result['nextStopEta'] ?? 0;
      totalSchoolMinutes = result['schoolEta'] ?? 0;
    }

    if (sendNotification && nextStopMinutes > 0 && remainingIds.isNotEmpty) {
      int nextStudentId = remainingIds[0];
      context.read<NotificationProvider>().notifyProximity(nextStudentId, nextStopMinutes);
    }

    if (mounted) {
      setState(() {
        _schoolEtaText = "$totalSchoolMinutes min";
        _nextStopEtaText = remainingIds.isNotEmpty ? "$nextStopMinutes min" : null;
      });
    }
  }

  // --- Configuração do Mapa e UI ---

  Future<BitmapDescriptor> _createNavigationIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = const Size(160, 160);
    final paint = Paint()
      ..color = AppPalette.primary800
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height * 0.8);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    }
    return BitmapDescriptor.defaultMarker;
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    if (_routeData.steps.isNotEmpty) {
      _speakInstruction(_routeData.steps.first.instruction);
    }
  }

  void _speakInstruction(String text) {
    if (_isDisposed || !_isSoundOn) return;
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

  void _setupMapUI(RouteData routeData) {
    List<PointLatLng> polylineCoordinates = PolylinePoints().decodePolyline(routeData.encodedPolyline);
    List<LatLng> latLngList = polylineCoordinates.map((p) => LatLng(p.latitude, p.longitude)).toList();
    Polyline routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      color: AppPalette.primary800.withOpacity(0.6),
      width: 7,
      zIndex: 1,
      points: latLngList,
    );

    setState(() {
      _markers.clear();
      _markers.add(
          Marker(
            markerId: MarkerId('school_${routeData.teamId}'),
            position: routeData.schoolLocation,
            infoWindow: InfoWindow(title: routeData.schoolName),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          )
      );
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

      _lastLocation = newLocation;
      final currentPosition = LatLng(newLocation.latitude!, newLocation.longitude!);

      if (_navigationIcon != null) {
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == 'van_location');
          _markers.add(
            Marker(
              markerId: const MarkerId('van_location'),
              position: currentPosition,
              icon: _navigationIcon!,
              flat: true,
              rotation: newLocation.heading ?? 0.0,
              anchor: const Offset(0.5, 0.5),
              zIndex: 2,
            ),
          );
        });
      }

      if (_isCameraCentered) {
        _isProgrammaticMovement = true;

        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentPosition,
              zoom: _navigationZoom,
              tilt: _navigationTilt,
              bearing: newLocation.heading ?? 0.0,
            ),
          ),
        ).then((_) {
          // Quando a animação terminar, liberamos a flag
          _isProgrammaticMovement = false;
        });
      }

      if (_hasArrivedAtStop || _isRouteFinished) return;

      LatLng targetLocation;
      String targetName;

      bool goingToSchool = _currentStopIndex == _routeData.students.length;

      if (goingToSchool) {
        targetLocation = _routeData.schoolLocation;
        targetName = _routeData.schoolName;
      } else {
        final currentStop = _routeData.students[_currentStopIndex];
        if (currentStop.latitude == null || currentStop.longitude == null) return;
        targetLocation = LatLng(currentStop.latitude!, currentStop.longitude!);
        targetName = currentStop.name;
      }

      final distanceToStop = _calculateDistance(
        currentPosition.latitude, currentPosition.longitude,
        targetLocation.latitude, targetLocation.longitude,
      );

      if (distanceToStop < _arrivalThreshold) {
        _flutterTts.stop();
        if (!_hasArrivedAtStop) {
          _triggerArrivalState(isSchool: goingToSchool, targetName: targetName);
          if (_sheetController.isAttached) {
            _sheetController.animateTo(0.4,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      }
      else if (_currentStepIndex < _routeData.steps.length - 1) {
        final nextManeuverPosition = _routeData.steps[_currentStepIndex].endLocation;
        final distanceToManeuver = _calculateDistance(
          currentPosition.latitude, currentPosition.longitude,
          nextManeuverPosition.latitude, nextManeuverPosition.longitude,
        );
        if (distanceToManeuver < 130) {
          _currentStepIndex++;
          final nextInstruction = _routeData.steps[_currentStepIndex].instruction;
          setState(() => _currentInstruction = nextInstruction);
          _speakInstruction(nextInstruction);
        }
      }
    });
  }

  void _triggerArrivalState({required bool isSchool, String? targetName}) {
    if (_hasArrivedAtStop) return;
    String instructionText;
    if (isSchool) {
      instructionText = "Chegamos na escola. Confirme para finalizar.";
    } else {
      final currentStudent = _routeData.students[_currentStopIndex];
      context.read<NotificationProvider>().notifyArrivalHome(currentStudent.id);
      instructionText = "Chegamos ao destino: $targetName";
    }
    setState(() {
      _hasArrivedAtStop = true;
      _currentInstruction = instructionText;
    });
    _speakInstruction(instructionText);
  }

  void _forceArrival({required bool isSchool, String? targetName}) {
    _triggerArrivalState(isSchool: isSchool, targetName: targetName);
  }

  void _cancelArrivalState() {
    setState(() {
      _hasArrivedAtStop = false;
      _currentInstruction = "Retornando à rota...";
    });
  }

  // --- AÇÕES DE USUÁRIO ---

  void _markAbsent() {
    setState(() {
      _currentStopIndex++;
      _hasArrivedAtStop = false;

      _refreshEtas(sendNotification: true);

      if (_currentStopIndex == _routeData.students.length) {
        _currentInstruction = "Todos a bordo! Próxima parada: ${_routeData.schoolName}";
      } else {
        final nextStudent = _routeData.students[_currentStopIndex];
        _currentInstruction = "Próxima parada: ${nextStudent.name}";
      }
      _speakInstruction(_currentInstruction);
    });
  }

  void _confirmBoarding() async {
    if (_isBoarding || _lastLocation == null) return;
    setState(() { _isBoarding = true; });

    final provider = context.read<NotificationProvider>();
    final currentStudent = _routeData.students[_currentStopIndex];
    final success = await provider.notifyBoarding(currentStudent.id);

    if (!mounted) return;
    if (success) {
      setState(() {
        _currentStopIndex++;
        _hasArrivedAtStop = false;
        _isBoarding = false;

        _refreshEtas(sendNotification: true);

        if (_currentStopIndex == _routeData.students.length) {
          _currentInstruction = "Todos a bordo! Próxima parada: ${_routeData.schoolName}";
        } else {
          final nextStudent = _routeData.students[_currentStopIndex];
          _currentInstruction = "Próxima parada: ${nextStudent.name}";
        }
        _speakInstruction(_currentInstruction);
      });
    } else {
      CustomSnackBar.show(context: context, label: provider.error ?? "Erro.", type: SnackBarType.error);
      setState(() { _isBoarding = false; });
    }
  }

  void _confirmArrivalAtSchool() async {
    setState(() { _isBoarding = true; });
    final provider = context.read<NotificationProvider>();
    final success = await provider.notifyArrivalSchool(_routeData.teamId);

    if (!mounted) return;
    if (success) {
      setState(() {
        _isRouteFinished = true;
        _locationSubscription?.cancel();
        _etaUpdateTimer?.cancel();
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Rota Finalizada"),
            content: const Text("Chegada registrada com sucesso."),
            actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text("OK"))],
          )
      );
    } else {
      CustomSnackBar.show(context: context, label: provider.error ?? "Erro.", type: SnackBarType.error);
      setState(() { _isBoarding = false; });
    }
  }

  // --- HELPERS ---

  double _calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

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

  // --- BUILDERS ---

  @override
  Widget build(BuildContext context) {
    final routeDataArgs = ModalRoute.of(context)?.settings.arguments;

    if (routeDataArgs == null || routeDataArgs is! RouteData) {
      return const Scaffold(body: Center(child: Text("Dados da rota não encontrados.")));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPalette.primary900),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Voltar',
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(routeDataArgs.students.first.latitude ?? 0.0, routeDataArgs.students.first.longitude ?? 0.0),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            trafficEnabled: true,
            onCameraMoveStarted: () {
              if (!_isProgrammaticMovement) {
                setState(() => _isCameraCentered = false);
              }
            },
          ),

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
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: IconButton(
                        icon: Icon(_isSoundOn ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isSoundOn = !_isSoundOn;
                            if (!_isSoundOn) _flutterTts.stop();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // 3. Painel Inferior
          if (!_isRouteFinished)
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.15,
              maxChildSize: 0.6,
              controller: _sheetController,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppPalette.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                  ),
                  child: _hasArrivedAtStop
                      ? _buildConfirmationCard(
                    context,
                    _currentStopIndex < routeDataArgs.students.length
                        ? routeDataArgs.students[_currentStopIndex]
                        : null,
                  )
                      : _buildStopList(
                    context,
                    scrollController,
                    routeDataArgs.students,
                  ),
                );
              },
            ),

          // 4. Botão Centralizar
          if (!_isCameraCentered && _lastLocation != null && !_isRouteFinished)
            Positioned(
              left: 16,
              bottom: MediaQuery.of(context).size.height * _sheetPosition + 16,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  if (_lastLocation?.latitude != null && _lastLocation?.longitude != null) {
                    setState(() => _isCameraCentered = true);
                    await _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(_lastLocation!.latitude!, _lastLocation!.longitude!),
                          zoom: _navigationZoom,
                          tilt: _navigationTilt,
                          bearing: _lastLocation?.heading ?? 0.0,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Centralizar'),
                backgroundColor: Colors.white,
                foregroundColor: AppPalette.primary800,
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGETS DE UI ---

  Widget _buildConfirmationCard(BuildContext context, Student? student) {
    final isSchool = student == null;

    final String displayName = isSchool ? _routeData.schoolName : student!.name;
    final String displayAddress = isSchool ? "Destino Final" : (student!.address ?? 'Endereço não informado');
    final String? displayImage = isSchool ? null : student!.image_profile;

    final Color primaryButtonColor = isSchool ? AppPalette.primary800 : AppPalette.green500;
    final VoidCallback? primaryAction = isSchool ? _confirmArrivalAtSchool : _confirmBoarding;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(
                color: AppPalette.neutral300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- CABEÇALHO COM BOTÃO VOLTAR ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppPalette.primary900),
                onPressed: _cancelArrivalState,
                tooltip: 'Voltar para lista',
              ),
              Expanded(
                child: Text(
                  isSchool ? 'Chegamos na Escola' : 'Confirmar embarque',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPalette.primary900),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isSchool ? AppPalette.primary800 : AppPalette.neutral150,
                backgroundImage: (displayImage != null && displayImage.isNotEmpty)
                    ? NetworkImage(displayImage)
                    : null,
                child: (displayImage == null || isSchool)
                    ? Icon(isSchool ? Icons.school : Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(displayAddress, style: const TextStyle(color: AppPalette.neutral600)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),

          // --- ÁREA DOS BOTÕES ---
          if (isSchool)
            ElevatedButton(
              onPressed: _isBoarding ? null : primaryAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryButtonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              child: _isBoarding
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                  : const Text('Finalizar Rota'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isBoarding ? null : _markAbsent,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.red700,
                      side: const BorderSide(color: AppPalette.red700),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Ausente'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isBoarding ? null : primaryAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    child: _isBoarding
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                        : const Text('Embarcar'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStopList(BuildContext context, ScrollController scrollController, List<Student> students) {
    final remainingStops = students.sublist(_currentStopIndex);
    bool nextIsSchool = _currentStopIndex == students.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(
                color: AppPalette.neutral300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Header de Tempo até Escola
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Center(
            child: Text.rich(
              TextSpan(
                text: "Chegada na escola em: ",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary900,
                ),
                children: [
                  TextSpan(
                    text: _schoolEtaText,
                    style: const TextStyle(
                      color: AppPalette.primary800, // Azul
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            nextIsSchool ? 'Destino Final' : 'Próximas paradas',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPalette.primary900),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: remainingStops.length + 1,
            itemBuilder: (context, index) {
              final bool isCurrentTarget = index == 0;

              // CASO ESCOLA
              if (index == remainingStops.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildStopTile(
                    name: _routeData.schoolName,
                    address: "Destino Final",
                    isNextTarget: isCurrentTarget, // Para pintar o endereço de azul
                    imageUrl: null,
                    isLastStop: true,
                    isSchool: true,
                    onTap: isCurrentTarget
                        ? () => _forceArrival(isSchool: true, targetName: _routeData.schoolName)
                        : null,
                  ),
                );
              }

              // CASO ALUNO
              final student = remainingStops[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildStopTile(
                  name: student.name,
                  address: student.address ?? 'Endereço não informado',
                  isNextTarget: isCurrentTarget, // Para pintar o endereço de azul

                  imageUrl: student.image_profile,
                  isLastStop: false,
                  etaBadge: isCurrentTarget ? _nextStopEtaText : null,
                  onTap: isCurrentTarget
                      ? () => _forceArrival(isSchool: false, targetName: student.name)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStopTile({
    required String name,
    required String address,
    required bool isLastStop,
    required bool isNextTarget, // NOVO: Indica se deve pintar o endereço de azul
    String? imageUrl,
    bool isSchool = false,
    VoidCallback? onTap,
    String? etaBadge,
  }) {
    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coluna Ícone/Linha
            SizedBox(
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                      isSchool ? Icons.school : Icons.location_on,
                      color: isSchool ? AppPalette.primary800 : AppPalette.red700,
                      size: 28
                  ),
                  if (!isLastStop)
                    Expanded(
                      child: Container(width: 2, color: AppPalette.neutral300),
                    )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/profile.png') as ImageProvider,
                    child: (imageUrl == null && isSchool)
                        ? const Icon(Icons.school, color: Colors.white)
                        : null,
                    backgroundColor: isSchool ? AppPalette.primary800 : AppPalette.neutral150,
                  ),
                  const SizedBox(width: 12),

                  // Infos
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        // Endereço muda de cor se for o próximo alvo
                        Text(
                            address,
                            style: TextStyle(
                                color: isNextTarget ? AppPalette.primary800 : AppPalette.neutral600,
                                fontSize: 12,
                                fontWeight: FontWeight.normal
                            )
                        ),
                      ],
                    ),
                  ),

                  // Badge de Tempo
                  if (etaBadge != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        etaBadge,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppPalette.primary900),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}