import 'team_model.dart';

class Trip {
  final int id;
  final String departureTime;
  final String arrivalTime;
  final String startingPoint;
  final int? schoolId;
  final String? schoolName;

  List<Team>? teams;

  Trip({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.startingPoint,
    this.schoolId,
    this.schoolName,
    this.teams,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
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