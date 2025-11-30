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
import 'package:check_van_frontend/model/student_model.dart'; // Import necessário para Student
import 'package:check_van_frontend/provider/notification_provider.dart';
import '../../../core/theme.dart';
import '../../../enum/snack_bar_type.dart';
import '../../widgets/route/active_route/confirmation_card.dart';
import '../../widgets/route/active_route/instruction_card.dart';
import '../../widgets/route/active_route/route_stop_list.dart';
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
  List<Student> _stops = []; // Lista filtrada de alunos confirmados para a rota

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LocationData? _lastLocation;
  BitmapDescriptor? _navigationIcon;

  int _currentStopIndex = 0;
  bool _hasArrivedAtStop = false;
  bool _isRouteFinished = false;
  bool _isBoarding = false;
  bool _firstNotificationSent = false;
  bool _isInit = false; // Flag para controlar inicialização única

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inicialização movida para cá para garantir que _routeData esteja pronto antes do build
    // e corrigir o LateInitializationError.
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is RouteData) {
        _routeData = args;

        // CORREÇÃO: Filtra alunos confirmados OU pendentes (null) para serem as paradas
        // Regra de negócio: Se pendente, considera que vai.
        _stops = _routeData.students.where((s) => s.isConfirmed != false).toList();

        if (_routeData.steps.isNotEmpty) {
          _currentInstruction = _routeData.steps.first.instruction;
        }

        // Configura UI inicial (Marcadores/Polylines) sem chamar setState
        _setupMapUI(_routeData, isInitialSetup: true);

        // Agende tarefas assíncronas para após o frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeTts();
          _setupLocationListener();

          if (!_firstNotificationSent && _stops.isNotEmpty) {
            _refreshEtas(sendNotification: true);
            _firstNotificationSent = true;
          }

          _startEtaTimer();
        });

        _isInit = true;
      }
    }
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
      // Usa _stops para lógica de paradas
      if (_currentStopIndex > 0 && _currentStopIndex < _stops.length) {
        final prev = _stops[_currentStopIndex - 1];
        if (prev.latitude != 0) startPoint = LatLng(prev.latitude, prev.longitude);
      } else {
        if (_routeData.schoolLocation.latitude.abs() > 0.0001) {
          startPoint = _routeData.schoolLocation;
        }
      }
    }

    if (startPoint == null) return;

    final provider = context.read<NotificationProvider>();

    List<int> remainingIds = [];
    if (_currentStopIndex < _stops.length) {
      for (int i = _currentStopIndex; i < _stops.length; i++) {
        remainingIds.add(_stops[i].id);
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
    // A UI já foi configurada no didChangeDependencies, não precisa chamar _setupMapUI aqui
  }

  void _setupMapUI(RouteData routeData, {bool isInitialSetup = false}) {
    List<PointLatLng> polylineCoordinates = PolylinePoints().decodePolyline(routeData.encodedPolyline);
    List<LatLng> latLngList = polylineCoordinates.map((p) => LatLng(p.latitude, p.longitude)).toList();
    Polyline routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      color: AppPalette.primary800.withOpacity(0.6),
      width: 7,
      zIndex: 1,
      points: latLngList,
    );

    // Prepara os marcadores
    final Set<Marker> newMarkers = {};
    newMarkers.add(
        Marker(
          markerId: MarkerId('school_${routeData.teamId}'),
          position: routeData.schoolLocation,
          infoWindow: InfoWindow(title: routeData.schoolName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        )
    );
    // Mostra apenas os alunos confirmados/pendentes no mapa (stops)
    for (var student in _stops) {
      if(student.latitude != 0 && student.longitude != 0){
        newMarkers.add(
          Marker(
            markerId: MarkerId('student_${student.id}'),
            position: LatLng(student.latitude, student.longitude),
            infoWindow: InfoWindow(title: student.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }

    if (isInitialSetup) {
      // Atualização direta sem setState para inicialização
      _markers.clear();
      _markers.addAll(newMarkers);
      _polylines.add(routePolyline);
    } else {
      // Atualização via setState para mudanças posteriores
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
        _polylines.add(routePolyline);
      });

      if (latLngList.isNotEmpty) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(_boundsFromLatLngList(latLngList), 60.0),
        );
      }
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
          _isProgrammaticMovement = false;
        });
      }

      if (_hasArrivedAtStop || _isRouteFinished) return;

      LatLng targetLocation;
      String targetName;

      bool goingToSchool = _currentStopIndex == _stops.length;

      if (goingToSchool) {
        targetLocation = _routeData.schoolLocation;
        targetName = _routeData.schoolName;
      } else {
        final currentStop = _stops[_currentStopIndex];
        if (currentStop.latitude == 0 || currentStop.longitude == 0) return;
        targetLocation = LatLng(currentStop.latitude, currentStop.longitude);
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
      final currentStudent = _stops[_currentStopIndex];
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

  void _markAbsent() {
    setState(() {
      _currentStopIndex++;
      _hasArrivedAtStop = false;

      _refreshEtas(sendNotification: true);

      if (_currentStopIndex == _stops.length) {
        _currentInstruction = "Todos a bordo! Próxima parada: ${_routeData.schoolName}";
      } else {
        final nextStudent = _stops[_currentStopIndex];
        _currentInstruction = "Próxima parada: ${nextStudent.name}";
      }
      _speakInstruction(_currentInstruction);
    });
  }

  void _confirmBoarding() async {
    if (_isBoarding || _lastLocation == null) return;
    setState(() { _isBoarding = true; });

    final provider = context.read<NotificationProvider>();
    final currentStudent = _stops[_currentStopIndex];
    final success = await provider.notifyBoarding(currentStudent.id);

    if (!mounted) return;
    if (success) {
      setState(() {
        _currentStopIndex++;
        _hasArrivedAtStop = false;
        _isBoarding = false;

        _refreshEtas(sendNotification: true);

        if (_currentStopIndex == _stops.length) {
          _currentInstruction = "Todos a bordo! Próxima parada: ${_routeData.schoolName}";
        } else {
          final nextStudent = _stops[_currentStopIndex];
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

  @override
  Widget build(BuildContext context) {
    final routeDataArgs = ModalRoute.of(context)?.settings.arguments;

    if (routeDataArgs == null || routeDataArgs is! RouteData) {
      return const Scaffold(body: Center(child: Text("Dados da rota não encontrados.")));
    }

    // Calcula um alvo seguro para a câmera inicial
    // Prioriza o primeiro aluno da rota (confirmado/pendente), senão a escola
    LatLng initialTarget = const LatLng(0, 0);

    // Filtro para alunos que vão participar da rota (Confirmados OU Pendentes)
    final goingList = routeDataArgs.students.where((s) => s.isConfirmed != false).toList();

    if (goingList.isNotEmpty && goingList.first.latitude != 0) {
      initialTarget = LatLng(goingList.first.latitude, goingList.first.longitude);
    } else if (routeDataArgs.schoolLocation.latitude != 0) {
      initialTarget = routeDataArgs.schoolLocation;
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
              target: initialTarget, // Alvo seguro (não quebra se lista for vazia)
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
            child: InstructionCard(
              instruction: _currentInstruction,
              isSoundOn: _isSoundOn,
              onToggleSound: () {
                setState(() {
                  _isSoundOn = !_isSoundOn;
                  if (!_isSoundOn) _flutterTts.stop();
                });
              },
            ),
          ),

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
                      ? ConfirmationCard(
                    student: _currentStopIndex < _stops.length
                        ? _stops[_currentStopIndex]
                        : null,
                    schoolName: _routeData.schoolName,
                    isBoarding: _isBoarding,
                    onCancel: _cancelArrivalState,
                    onConfirm: _currentStopIndex < _stops.length
                        ? _confirmBoarding
                        : _confirmArrivalAtSchool,
                    onMarkAbsent: _markAbsent,
                  )
                      : RouteStopList(
                    scrollController: scrollController,
                    students: _stops, // Mostra apenas paradas válidas (incluindo pendentes)
                    currentStopIndex: _currentStopIndex,
                    schoolName: _routeData.schoolName,
                    schoolEtaText: _schoolEtaText,
                    nextStopEtaText: _nextStopEtaText,
                    onForceArrival: (isSchool, targetName) {
                      _forceArrival(isSchool: isSchool, targetName: targetName);
                    },
                  ),
                );
              },
            ),

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
}