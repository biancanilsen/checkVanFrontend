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

// Imports do seu projeto
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
  // --- Controladores ---
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  late GoogleMapController _mapController;
  final _sheetController = DraggableScrollableController();
  final Location _location = Location();
  final FlutterTts _flutterTts = FlutterTts();
  StreamSubscription<LocationData>? _locationSubscription;

  // --- Dados e Estado ---
  late final RouteData _routeData;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LocationData? _lastLocation;
  BitmapDescriptor? _navigationIcon;

  // Variáveis de Fluxo
  int _currentStopIndex = 0;        // Índice do alvo atual (Aluno ou Escola se for o último)
  bool _hasArrivedAtStop = false;   // True = GPS detectou chegada (mostra card de ação)
  bool _isRouteFinished = false;    // True = Rota concluída totalmente
  bool _isBoarding = false;         // True = Loading do botão (spinner)

  // Variáveis de UI/Nav
  double _sheetPosition = 0.4;
  bool _isCameraCentered = true;
  bool _isSoundOn = true;
  String _currentInstruction = "Iniciando a rota...";
  int _currentStepIndex = 0;
  bool _isDisposed = false;

  // Configurações
  static const double _arrivalThreshold = 30.0; // 30 metros
  static const double _navigationZoom = 18.0;
  static const double _navigationTilt = 45.0;

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
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
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
      color: AppPalette.primary800,
      width: 6,
      points: latLngList,
    );

    setState(() {
      _markers.clear();
      // Escola
      _markers.add(
          Marker(
            markerId: MarkerId('school_${routeData.teamId}'),
            position: routeData.schoolLocation,
            infoWindow: InfoWindow(title: routeData.schoolName),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          )
      );
      // Alunos
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

  // --- LÓGICA PRINCIPAL DE NAVEGAÇÃO ---

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

      // 1. Atualiza Marcador da Van
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

      // 2. Animação da Câmera
      if (_isCameraCentered) {
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentPosition,
              zoom: _navigationZoom,
              tilt: _navigationTilt,
              bearing: newLocation.heading ?? 0.0,
            ),
          ),
        );
      }

      // 3. LÓGICA DE DETECÇÃO DE CHEGADA
      if (_hasArrivedAtStop || _isRouteFinished) return;

      LatLng targetLocation;
      String targetName;

      // Verifica se o destino atual é a ESCOLA (quando o index iguala o tamanho da lista)
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

      // --- VERIFICAÇÃO DE PROXIMIDADE ---
      if (distanceToStop < _arrivalThreshold) {
        _flutterTts.stop();

        // Se ainda não tínhamos detectado a chegada, agora detectamos
        if (!_hasArrivedAtStop) {

          String instructionText;

          if (goingToSchool) {
            // >>> CASO ESCOLA: CHEGADA MANUAL <<<
            instructionText = "Chegamos na escola. Confirme para finalizar.";
          } else {
            // >>> CASO ALUNO: CHEGADA AUTOMÁTICA (NOTIFICAÇÃO) <<<
            final currentStudent = _routeData.students[_currentStopIndex];
            context.read<NotificationProvider>().notifyArrivalHome(currentStudent.id);
            instructionText = "Chegamos ao destino: $targetName";
          }

          // Atualiza UI para mostrar o Card de Confirmação
          setState(() {
            _hasArrivedAtStop = true;
            _currentInstruction = instructionText;
          });
          _speakInstruction(instructionText);

          // Abre o painel inferior
          if (_sheetController.isAttached) {
            _sheetController.animateTo(0.4,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      }
      // Navegação por Voz (Manobras)
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

  // --- AÇÕES DE USUÁRIO ---

  // Botão "Ausente" (Pula o aluno sem chamar backend)
  void _markAbsent() {
    // Não bloqueia a UI com _isBoarding pois não tem chamada de rede
    setState(() {
      _currentStopIndex++; // Pula para o próximo
      _hasArrivedAtStop = false; // Volta para a lista de rota

      // Prepara a próxima instrução
      if (_currentStopIndex == _routeData.students.length) {
        _currentInstruction = "Todos a bordo! Próxima parada: ${_routeData.schoolName}";
      } else {
        final nextStudent = _routeData.students[_currentStopIndex];
        _currentInstruction = "Próxima parada: ${nextStudent.name}";
      }
      _speakInstruction(_currentInstruction);
    });
  }

  // Botão "Embarcar" (Apenas para alunos)
  void _confirmBoarding() async {
    if (_isBoarding || _lastLocation == null) return;

    setState(() { _isBoarding = true; });

    final provider = context.read<NotificationProvider>();
    final currentStudent = _routeData.students[_currentStopIndex];

    // 1. Chama endpoint específico
    final success = await provider.notifyBoarding(currentStudent.id);

    if (!mounted) return;

    if (success) {
      setState(() {
        _currentStopIndex++; // Avança para o próximo
        _hasArrivedAtStop = false; // Sai do modo "Chegada"
        _isBoarding = false;

        // Prepara a próxima instrução
        if (_currentStopIndex == _routeData.students.length) {
          _currentInstruction = "Todos a bordo! Próxima parada: ${_routeData.schoolName}";
        } else {
          final nextStudent = _routeData.students[_currentStopIndex];
          _currentInstruction = "Próxima parada: ${nextStudent.name}";
        }
        _speakInstruction(_currentInstruction);
      });
    } else {
      CustomSnackBar.show(
        context: context,
        label: provider.error ?? "Erro ao registrar embarque.",
        type: SnackBarType.error,
      );
      setState(() { _isBoarding = false; });
    }
  }

  // Botão "Finalizar Rota" (Apenas para escola, acionado manualmente)
  void _confirmArrivalAtSchool() async {
    setState(() { _isBoarding = true; });

    final provider = context.read<NotificationProvider>();

    // 1. Chama endpoint específico de escola
    final success = await provider.notifyArrivalSchool(_routeData.teamId);

    if (!mounted) return;

    if (success) {
      // Sucesso: Encerra
      setState(() {
        _isRouteFinished = true;
        _locationSubscription?.cancel();
      });

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Rota Finalizada"),
            content: const Text("Chegada na escola registrada e responsáveis notificados."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          )
      );
    } else {
      // Erro
      CustomSnackBar.show(
        context: context,
        label: provider.error ?? "Erro ao notificar chegada na escola.",
        type: SnackBarType.error,
      );
      setState(() { _isBoarding = false; });
    }
  }

  // --- HELPERS ---

  double _calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000; // metros
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
        foregroundColor: AppPalette.primary900,
      ),
      body: Stack(
        children: [
          // 1. Mapa
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
            onCameraMoveStarted: () {
              if (_isCameraCentered) setState(() => _isCameraCentered = false);
            },
          ),

          // 2. Card de Instrução (Topo)
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
                    // Se o index atual for < lista, é aluno. Se for igual, é escola (null).
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

  // Exibe card quando chega no destino (Aluno ou Escola)
  Widget _buildConfirmationCard(BuildContext context, Student? student) {
    // Se student for null, significa que estamos no passo final (Escola)
    final isSchool = student == null;

    // Configura os textos e cores baseados se é Escola ou Aluno
    final String displayName = isSchool ? _routeData.schoolName : student!.name;
    final String displayAddress = isSchool ? "Destino Final" : (student!.address ?? 'Endereço não informado');
    final String? displayImage = isSchool ? null : student!.image_profile;

    // Se for escola, o botão é azul. Se for aluno, verde.
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
          const SizedBox(height: 24),
          Text(
            isSchool ? 'Chegamos na Escola' : 'Confirmar embarque',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppPalette.primary900),
          ),
          const SizedBox(height: 24),

          // Dados do Aluno ou Escola
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
          // Se for Escola: Apenas um botão para finalizar
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
          // Se for Aluno: Botões "Ausente" e "Embarcar" lado a lado
            Row(
              children: [
                // Botão AUSENTE
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
                // Botão EMBARCAR
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

  // Lista de próximas paradas
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            nextIsSchool ? 'Destino Final' : 'Próximas paradas',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppPalette.primary900),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: remainingStops.length + 1,
            itemBuilder: (context, index) {
              // Último item da lista visual sempre é a escola
              if (index == remainingStops.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildStopTile(
                    name: _routeData.schoolName,
                    address: "Destino Final",
                    imageUrl: null,
                    isLastStop: true,
                    isSchool: true,
                  ),
                );
              }
              final student = remainingStops[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildStopTile(
                  name: student.name,
                  address: student.address ?? 'Endereço não informado',
                  imageUrl: student.image_profile,
                  isLastStop: false,
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
    String? imageUrl,
    bool isSchool = false,
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
}