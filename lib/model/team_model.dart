import 'package:check_van_frontend/features/widgets/team/period_selector.dart'; // Import for Period enum
import 'student_model.dart'; // Assuming you have this model

class Team {
  final int id;
  final String name;
  final int schoolId;
  final double? startingLat;
  final double? startingLon;
  final String? plate;     // Van name from UI
  final String? nickname;  // Van plate from UI
  final int? capacity;    // Van capacity
  final String? code;      // Code displayed in list
  final Period? period;    // Period displayed in list
  final int studentCount; // Student count displayed in list
  final List<Student>? students; // Optional list of students

  Team({
    required this.id,
    required this.name,
    required this.schoolId,
    this.startingLat,
    this.startingLon,
    this.plate,
    this.nickname,
    this.capacity,
    this.code,
    this.period,
    required this.studentCount,
    this.students,
  });

  // Helper function to safely parse Period from String
  static Period? _parsePeriod(String? periodString) {
    if (periodString == null) return null;
    try {
      return Period.values.firstWhere(
            (e) => e.toString().split('.').last == periodString.toLowerCase(),
      );
    } catch (e) {
      return null; // Return null if parsing fails
    }
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    // Determine student count: either directly from a field or by counting the list
    int count = json['studentCount'] ?? (json['students'] as List?)?.length ?? 0;

    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Turma sem nome',
      schoolId: json['school_id'] ?? 0, // Assuming backend sends school_id
      startingLat: (json['starting_lat'] as num?)?.toDouble(),
      startingLon: (json['starting_lon'] as num?)?.toDouble(),
      // Assuming backend might return van details nested or directly
      plate: json['van']?['plate'] ?? json['plate'],
      nickname: json['van']?['nickname'] ?? json['nickname'],
      capacity: json['van']?['capacity'] ?? json['capacity'],
      code: json['code'], // Assuming backend sends code
      period: _parsePeriod(json['period']), // Assuming backend sends period as string 'morning', 'afternoon', 'night'
      studentCount: count,
      students: json.containsKey('students') && json['students'] != null
          ? (json['students'] as List).map((s) => Student.fromJson(s)).toList()
          : null, // Keep it nullable
    );
  }

  // Optional: Add copyWith if needed
  Team copyWith({
    int? id,
    String? name,
    int? schoolId,
    double? startingLat,
    double? startingLon,
    String? plate,
    String? nickname,
    int? capacity,
    String? code,
    Period? period,
    int? studentCount,
    List<Student>? students,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolId: schoolId ?? this.schoolId,
      startingLat: startingLat ?? this.startingLat,
      startingLon: startingLon ?? this.startingLon,
      plate: plate ?? this.plate,
      nickname: nickname ?? this.nickname,
      capacity: capacity ?? this.capacity,
      code: code ?? this.code,
      period: period ?? this.period,
      studentCount: studentCount ?? this.studentCount,
      students: students ?? this.students,
    );
  }
}
