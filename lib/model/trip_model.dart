import 'package:check_van_frontend/model/team_model.dart';

class Trip {
  final int id;
  final String departureTime;
  final String arrivalTime;
  final String startingPoint;
  final String endingPoint;
  List<Team>? teams;


  Trip({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.startingPoint,
    required this.endingPoint,
    this.teams,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    print('MAPEANDO JSON PARA OBJETO TRIP: $json');
    return Trip(
      id: json['id'] ?? 0,
      departureTime: json['departure_time'] ?? '00:00',
      arrivalTime: json['arrival_time'] ?? '00:00',
      startingPoint: json['starting_point'] ?? 'Ponto de partida não informado',
      endingPoint: json['ending_point'] ?? 'Ponto de chegada não informado',
    );
  }
}