import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/student_model.dart';
import '../model/team_model.dart';
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
  final Map<int, bool> _isLoadingTeams = {};
  bool isLoadingTeams(int tripId) => _isLoadingTeams[tripId] ?? false;

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

  Future<void> getTeamsForTrip(int tripId) async {
    _isLoadingTeams[tripId] = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      // 1. Busca a lista de turmas da viagem
      final teamsResponse = await http.get(
        Uri.parse('${Endpoints.getTeamsByTripId}/$tripId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (teamsResponse.statusCode != 200) throw Exception('Falha ao buscar turmas');

      final teamsData = jsonDecode(teamsResponse.body);
      final List<Team> teams = (teamsData['teams'] as List)
          .map((json) => Team.fromJson(json))
          .toList();

      // 2. Para cada turma, cria uma "promessa" de buscar seus alunos
      final studentFetchFutures = teams.map((team) async {
        final studentsResponse = await http.get(
          Uri.parse('${Endpoints.getStudentsByTeamId}/${team.id}'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (studentsResponse.statusCode == 200) {
          final studentsData = jsonDecode(studentsResponse.body);
          final studentList = (studentsData['students'] as List)
              .map((json) => Student.fromJson(json))
              .toList();
          // Anexa a lista de alunos ao seu objeto de turma
          team.students = studentList;
        }
        return team;
      }).toList();

      // 3. Usa Future.wait para executar todas as buscas de alunos em paralelo
      final teamsWithStudents = await Future.wait(studentFetchFutures);

      // 4. Atualiza o estado principal
      final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
      if (tripIndex != -1) {
        _trips[tripIndex].teams = teamsWithStudents;
      }

    } catch (e) {
      print('Erro ao buscar turmas e alunos: $e');
    } finally {
      _isLoadingTeams[tripId] = false;
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