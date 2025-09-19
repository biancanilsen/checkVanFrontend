import 'student_model.dart';
import 'trip_model.dart';

class Team {
  final int id;
  final String name;
  final Trip? trip; // 1. Marque o trip como opcional (pode ser nulo)
  List<Student> students; // 2. Remova o 'final' para permitir a atribuição posterior

  Team({
    required this.id,
    required this.name,
    this.trip, // Construtor atualizado
    required this.students,
  });

  Team copyWith({
    List<Student>? students,
  }) {
    return Team(
      id: this.id,
      name: this.name,
      trip: this.trip,
      students: students ?? this.students,
    );
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    // 3. Lógica mais segura para parsing
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Turma sem nome',

      // Verifica se o campo 'trip' existe antes de tentar converter
      trip: json.containsKey('trip') && json['trip'] != null
          ? Trip.fromJson(json['trip'])
          : null,

      // Verifica se o campo 'students' existe, senão, começa com uma lista vazia
      students: json.containsKey('students') && json['students'] != null
          ? (json['students'] as List).map((s) => Student.fromJson(s)).toList()
          : [],
    );
  }
}