import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../network/endpoints.dart';
import '../utils/user_session.dart';

class NotificationProvider extends ChangeNotifier {
  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<Notification> get notifications => _notifications;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Notification? get nextNotification =>
      _notifications.isEmpty ? null : _notifications.first;

  List<Notification> get scheduledNotifications =>
      _notifications.isEmpty ? [] : _notifications.skip(1).toList();

  Future<bool> sendLocationUpdate(int teamId, double lat, double lon,
      String tripType) async {
    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final url = Uri.parse(Endpoints.updateLocation);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        // 2. Adicionado 'tripType' ao JSON
        body: jsonEncode({
          'teamId': teamId,
          'lat': lat,
          'lon': lon,
          'tripType': tripType,
        }),
      );

      if (response.statusCode == 200) {
        print('Localização e status de embarque processados pelo backend.');
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Falha ao processar localização.';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> _postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final url = Uri.parse(endpoint);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        print('Erro backend: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('Erro request: $e');
      return false;
    }
  }

  // 1. Notificar Proximidade (Tempo estimado)
  Future<bool> notifyProximity(int studentId, int minutes) async {
    return _postRequest(Endpoints.notifyProximity, {
      'studentId': studentId,
      'minutes': minutes
    });
  }

  // 2. Notificar Embarque
  Future<bool> notifyBoarding(int studentId) async {
    return _postRequest(Endpoints.notifyBoarding, {'studentId': studentId});
  }

  // 3. Notificar Chegada na Casa (Automático - Já está aqui)
  Future<bool> notifyArrivalHome(int studentId) async {
    return _postRequest(Endpoints.notifyArrivalHome, {'studentId': studentId});
  }

  // 4. Notificar Chegada na Escola
  Future<bool> notifyArrivalSchool(int teamId) async {
    return _postRequest(Endpoints.notifyArrivalSchool, {'teamId': teamId});
  }

  Future<int?> getRealTimeEta(double currentLat, double currentLon, int studentId) async {
    try {
      final token = await UserSession.getToken();
      final url = Uri.parse(Endpoints.calculateEta); // Certifique-se de adicionar no Endpoints

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lat': currentLat,
          'lon': currentLon,
          'studentId': studentId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['minutes']; // Pode ser null ou int
      }
    } catch (e) {
      print('Erro ao buscar ETA real: $e');
    }
    return null; // Retorna null se der erro, para usarmos o cálculo local
  }

  // Método novo que retorna os dois tempos
  Future<Map<String, int>?> calculateRouteEtas({
    required double currentLat,
    required double currentLon,
    required List<int> remainingStudentIds,
    required int teamId,
  }) async {
    try {
      final token = await UserSession.getToken();
      final url = Uri.parse(Endpoints.calculateRouteEtas);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentLat': currentLat,
          'currentLon': currentLon,
          'remainingStudentIds': remainingStudentIds,
          'teamId': teamId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'nextStopEta': data['nextStopEta'] ?? 0,
          'schoolEta': data['schoolEta'] ?? 0,
        };
      }
    } catch (e) {
      print('Erro ao calcular ETAs da rota: $e');
    }
    return null;
  }
}