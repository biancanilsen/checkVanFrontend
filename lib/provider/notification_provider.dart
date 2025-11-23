import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../network/endpoints.dart';
import '../utils/user_session.dart';
import '../services/navigation_service.dart';

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
        body: jsonEncode({
          'teamId': teamId,
          'lat': lat,
          'lon': lon,
          'tripType': tripType,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Falha ao processar localização.';
        return false;
      }
    } on TimeoutException catch (_) {
      // Location updates are silent, maybe don't force error screen here to not interrupt driving?
      // Or force if critical. Let's keep it consistent with request:
      NavigationService.forceErrorScreen();
      return false;
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
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
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        print('Erro backend: ${data['message']}');
        return false;
      }
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } catch (e) {
      print('Erro request: $e');
      NavigationService.forceErrorScreen();
      return false;
    }
  }

  Future<bool> notifyProximity(int studentId, int minutes) async {
    return _postRequest(Endpoints.notifyProximity, {
      'studentId': studentId,
      'minutes': minutes
    });
  }

  Future<bool> notifyBoarding(int studentId) async {
    return _postRequest(Endpoints.notifyBoarding, {'studentId': studentId});
  }

  Future<bool> notifyArrivalHome(int studentId) async {
    return _postRequest(Endpoints.notifyArrivalHome, {'studentId': studentId});
  }

  Future<bool> notifyArrivalSchool(int teamId) async {
    return _postRequest(Endpoints.notifyArrivalSchool, {'teamId': teamId});
  }

  Future<int?> getRealTimeEta(double currentLat, double currentLon, int studentId) async {
    try {
      final token = await UserSession.getToken();
      final url = Uri.parse(Endpoints.calculateEta);

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
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['minutes'];
      }
    } on TimeoutException catch (_) {
      // Silent fail for ETA calculation (fallback to local) or force error?
      // Usually background calculations shouldn't break UI flow, but per instruction:
      NavigationService.forceErrorScreen();
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
    } catch (e) {
      print('Erro ao buscar ETA real: $e');
    }
    return null;
  }

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
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'nextStopEta': data['nextStopEta'] ?? 0,
          'schoolEta': data['schoolEta'] ?? 0,
        };
      }
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
    } catch (e) {
      print('Erro ao calcular ETAs da rota: $e');
      NavigationService.forceErrorScreen();
    }
    return null;
  }
}