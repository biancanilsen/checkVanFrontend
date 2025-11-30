import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Necessário para LatLng

import '../model/route_model.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class RouteProvider with ChangeNotifier {
  final ApiClient _client = ApiClient();
  bool _isLoading = false;
  String? _error;
  RouteData? _routeData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  RouteData? get routeData => _routeData;

  Future<bool> generateRoute({
    required int teamId,
    required String tripType, // 'GOING' ou 'RETURNING'
    required DateTime date,   // Data da viagem
    LatLng? currentLocation,  // Localização atual opcional
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();

      // Formata a data para yyyy-MM-dd
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Prepara os parâmetros da query
      final Map<String, String> queryParams = {
        'date': formattedDate,
        'tripType': tripType,
      };

      // Se tiver localização atual, adiciona aos parâmetros
      if (currentLocation != null) {
        queryParams['currentLat'] = currentLocation.latitude.toString();
        queryParams['currentLon'] = currentLocation.longitude.toString();
      }

      // Constrói a URL com Query Parameters
      // Nota: Certifique-se que Endpoints.baseUrl não termine com barra ou ajuste conforme necessário
      final uri = Uri.parse('${Endpoints.baseUrl}/routeGenerator/generate/$teamId')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Instancia o RouteData passando os argumentos de contexto (teamId e tripType)
        _routeData = RouteData.fromJson(data, teamId, tripType);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = jsonDecode(response.body)['message'] ?? 'Erro ao gerar rota';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}