import 'student_model.dart';
import 'trip_model.dart';

class Team {
  final int id;
  final String name;
  final Trip? trip;
  List<Student> students;

  Team({
    required this.id,
    required this.name,
    this.trip,
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
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Turma sem nome',

      trip: json.containsKey('trip') && json['trip'] != null
          ? Trip.fromJson(json['trip'])
          : null,

      students: json.containsKey('students') && json['students'] != null
          ? (json['students'] as List).map((s) => Student.fromJson(s)).toList()
          : [],
    );
  }
}