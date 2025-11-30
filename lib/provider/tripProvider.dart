import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/trip_model.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';
import '../services/navigation_service.dart';

class TripProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Trip? get nextTrip => _trips.isEmpty ? null : _trips.first;
  List<Trip> get scheduledTrips => _trips.isEmpty ? [] : _trips.skip(1).toList();

  Future<void> fetchNextTrips() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await _client.get(
        Uri.parse(Endpoints.getNextTrips),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tripListJson = data['trips'];
        _trips = tripListJson.map((json) => Trip.fromJson(json)).toList();
      } else {
        final data = jsonDecode(response.body);
        if (data['message'] == 'Nenhuma viagem futura encontrada.') {
          _trips = [];
        } else {
          _error = data['message'] ?? 'Falha ao carregar viagens.';
          _trips = [];
        }
      }
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
      _trips = [];
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
      _trips = [];
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      _trips = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}