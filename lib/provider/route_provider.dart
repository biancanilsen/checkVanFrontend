import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/route_model.dart';
import '../model/student_model.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class RouteProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  RouteData? _routeData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  RouteData? get routeData => _routeData;

  Future<bool> generateRoute({required int teamId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.get(
        Uri.parse('${Endpoints.generateRoute}/$teamId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Mapeia os alunos da resposta (isso já estava correto)
        final List<dynamic> studentsJson = data['studentsGoing'] ?? [];
        final students = studentsJson.map((json) => Student.fromJson(json)).toList();

        // --- AJUSTE AQUI: Construindo a lista de waypoints a partir dos "legs" ---
        final List<dynamic> legsJson = data['route']?['legs'] ?? [];
        final List<Waypoint> waypoints = [];

        if (legsJson.isNotEmpty) {
          // Adiciona o ponto de partida do primeiro "leg"
          final startLocation = legsJson.first['start_location'];
          waypoints.add(Waypoint(
            lat: (startLocation['lat'] as num).toDouble(),
            lon: (startLocation['lng'] as num).toDouble(),
          ));

          // Adiciona os pontos de chegada de cada "leg" (que são as paradas)
          for (var leg in legsJson) {
            final endLocation = leg['end_location'];
            waypoints.add(Waypoint(
              lat: (endLocation['lat'] as num).toDouble(),
              lon: (endLocation['lng'] as num).toDouble(),
            ));
          }
        }

        _routeData = RouteData(students: students, waypoints: waypoints);
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Falha ao gerar a rota.');
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}