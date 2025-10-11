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

  final Map<int, bool> _isLoadingTeams = {};

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isLoadingTeams(int tripId) => _isLoadingTeams[tripId] ?? false;

  Future<void> getTrips() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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

      final teamsResponse = await http.get(
        Uri.parse('${Endpoints.getTeamsByTripId}/$tripId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (teamsResponse.statusCode != 200) {
        throw Exception('Falha ao buscar turmas (Cód: ${teamsResponse.statusCode})');
      }

      final teamsData = jsonDecode(teamsResponse.body);

      final List<dynamic> teamListJson = teamsData['teams'] ?? [];

      final List<Team> teams = teamListJson
          .map((json) => Team.fromJson(json))
          .toList();

      final studentFetchFutures = teams.map((team) async {
        final studentsResponse = await http.get(
          Uri.parse('${Endpoints.getStudentsByTeamId}/${team.id}'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (studentsResponse.statusCode == 200) {
          final studentsData = jsonDecode(studentsResponse.body);

          final List<dynamic> studentListJson = studentsData['students'] ?? [];

          final studentList = studentListJson
              .map((json) => Student.fromJson(json))
              .toList();

          return team.copyWith(students: studentList);
        }
        return team;
      }).toList();

      final teamsWithStudents = await Future.wait(studentFetchFutures);

      final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
      if (tripIndex != -1) {
        _trips[tripIndex].teams = teamsWithStudents;
      }

    } catch (e) {
      _error = 'Erro ao buscar detalhes da viagem: ${e.toString()}';
      print(_error);
    } finally {
      _isLoadingTeams[tripId] = false;
      notifyListeners();
    }
  }

  Future<bool> addTrip({
    required TimeOfDay departureTime,
    required TimeOfDay arrivalTime,
    required String startingPoint,
    required int schoolId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final now = DateTime.now();
      final departureDateTime = DateTime(now.year, now.month, now.day, departureTime.hour, departureTime.minute).toIso8601String();
      final arrivalDateTime = DateTime(now.year, now.month, now.day, arrivalTime.hour, arrivalTime.minute).toIso8601String();

      final body = {
        'departure_time': departureDateTime,
        'arrival_time': arrivalDateTime,
        'starting_point': startingPoint,
        'school_id': schoolId,
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
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTrip({
    required int id,
    required TimeOfDay departureTime,
    required TimeOfDay arrivalTime,
    required String startingPoint,
    required int schoolId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final now = DateTime.now();
      final departureDateTime = DateTime(now.year, now.month, now.day, departureTime.hour, departureTime.minute).toIso8601String();
      final arrivalDateTime = DateTime(now.year, now.month, now.day, arrivalTime.hour, arrivalTime.minute).toIso8601String();

      final body = {
        'id': id,
        'departure_time': departureDateTime,
        'arrival_time': arrivalDateTime,
        'starting_point': startingPoint,
        'school_id': schoolId,
      };

      final response = await http.put(
        Uri.parse(Endpoints.updateTrip),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await getTrips();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao atualizar viagem.';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteTrip(int tripId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await UserSession.getToken();
      if (token == null) throw Exception('Usuário não autenticado.');

      final response = await http.delete(
        Uri.parse(Endpoints.deleteTrip),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id': tripId}),
      );

      if (response.statusCode == 200) {
        await getTrips();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Erro ao excluir viagem.';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
      notifyListeners();
    }
  }
}