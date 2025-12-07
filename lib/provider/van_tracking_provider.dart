import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class VanTrackingProvider extends ChangeNotifier {
  // Coordenada mais recente da van
  LatLng? _vanPosition;
  LatLng? get vanPosition => _vanPosition;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  int? _trackingTeamId;

  // Canal de comunicação WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;

  void startTracking(int teamId) async {
    _trackingTeamId = teamId;
    _isConnecting = true;
    _vanPosition = null;

    final token = await UserSession.getToken();
    if (token == null) {
      _isConnecting = false;
      notifyListeners();
      return;
    }

    final wsUrl = Endpoints.baseUrl.replaceFirst('http', 'ws');
    final uri = Uri.parse('$wsUrl/tracking?token=$token&teamId=$teamId');

    try {
      _channel = WebSocketChannel.connect(uri);

      _streamSubscription = _channel!.stream.listen(
            (data) {
          if (_isConnecting) {
            _isConnecting = false;
            notifyListeners();
          }
          _handleReceivedLocation(data);
        },
        onError: (error) {
          print('WS Error: $error');
          stopTracking();
        },
        onDone: () {
          print('WS Done: Conexão fechada.');
          stopTracking();
        },
      );

      Future.delayed(const Duration(seconds: 5), () {
        if (_isConnecting) {
          _isConnecting = false;
          notifyListeners();
        }
      });

    } catch (e) {
      print('Falha ao conectar WS: $e');
      _isConnecting = false;
      notifyListeners();
    }
  }

  void _handleReceivedLocation(dynamic data) {
    try {
      final json = jsonDecode(data);
      if (json['lat'] != null && json['lon'] != null) {
        _vanPosition = LatLng(json['lat'], json['lon']);
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao decodificar localização: $e');
    }
  }

  void stopTracking() {
    _streamSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _trackingTeamId = null;
    _isConnecting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}