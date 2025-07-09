import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/trip_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class TripProvider extends ChangeNotifier {
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getTrips() async {
    _isLoading = true;
    _error = null;

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.get(
        Uri.parse(Endpoints.getAllTrips),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> tripListJson = [];
        if (data is Map && data.containsKey('trips')) {
          tripListJson = data['trips'];
        } else if (data is List) {
          tripListJson = data;
        }

        _trips = tripListJson.map((json) => Trip.fromJson(json)).toList();
        _trips.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        _error = null;
      } else {
        _error = 'Falha ao carregar viagens (Cód: ${response.statusCode}).';
        _trips = [];
      }
    } catch (e) {
      _error = 'Erro de conexão ou formato: ${e.toString()}';
      _trips = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTrip({
    required TimeOfDay departureTime,
    required TimeOfDay arrivalTime,
    required String startingPoint,
    required String endingPoint,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final departure = '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}';
      final arrival = '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';

      final body = {
        'departure_time': departure,
        'arrival_time': arrival,
        'starting_point': startingPoint,
        'ending_point': endingPoint,
      };

      final response = await http.post(
        Uri.parse(Endpoints.tripRegistration),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        await getTrips();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao adicionar viagem.';
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}