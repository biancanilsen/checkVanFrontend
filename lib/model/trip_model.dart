import 'package:intl/intl.dart';
import 'team_model.dart'; // 1. Importe o modelo da Turma

class Trip {
  final int id;
  final String departureTime;
  final String arrivalTime;
  final String startingPoint;
  final int? schoolId;
  final String? schoolName;

  // 2. Adicione este campo para guardar a lista de turmas
  // A interrogação (?) indica que ele pode ser nulo (inicialmente será)
  List<Team>? teams;

  Trip({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.startingPoint,
    this.schoolId,
    this.schoolName,
    this.teams, // 3. Adicione o campo ao construtor
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    // A função fromJson permanece a mesma, pois 'teams' é carregado depois
    return Trip(
      id: json['id'] ?? 0,
      departureTime: json['departure_time'] ?? '00:00',
      arrivalTime: json['arrival_time'] ?? '00:00',
      startingPoint: json['starting_point'] ?? 'Ponto de partida não informado',
      schoolId: json['school'] != null ? json['school']['id'] : null,
      schoolName: json['school'] != null ? json['school']['name'] : 'Destino não informado',
    );
  }
}