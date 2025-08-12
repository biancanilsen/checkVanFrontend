// lib/model/team_model.dart

import 'package:check_van_frontend/model/student_model.dart';

class Team {
  final int id;
  final String name;
  final int driverId;
  final int tripId;

  // 2. Adicione uma lista de alunos (pode ser nula)
  List<Student>? students;

  Team({
    required this.id,
    required this.name,
    required this.driverId,
    required this.tripId,
    this.students,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nome da Turma Indisponível',
      driverId: json['driver_id'] ?? 0,
      tripId: json['trip_id'] ?? 0,
    );
  }
}