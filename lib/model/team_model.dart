import 'school_model.dart';
import 'student_model.dart' hide School;

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class Team {
  final int id;
  final String name;
  final String? code;
  final String shift;
  final int schoolId;
  final int driverId;
  final int? vanId;
  final double? startingLat;
  final double? startingLon;

  final String? address;
  final double? distanceTotal;
  final int? durationGoing;
  final int? durationReturn;

  final School school;
  final List<Student> students;

  Team({
    required this.id,
    required this.name,
    this.code,
    required this.shift,
    required this.schoolId,
    required this.driverId,
    this.vanId,
    this.startingLat,
    this.startingLon,
    required this.school,
    required this.students,
    this.address,
    this.distanceTotal,
    this.durationGoing,
    this.durationReturn,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    var studentList = <Student>[];
    if (json['student_team'] != null) {
      studentList = (json['student_team'] as List)
          .map((st) => Student.fromJson(st['student']))
          .toList();
    }

    return Team(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      shift: json['shift'],
      schoolId: json['school_id'],
      driverId: json['driver_id'],
      vanId: json['van_id'],
      startingLat: _parseDouble(json['starting_lat']),
      startingLon: _parseDouble(json['starting_lon']),
      school: School.fromJson(json['school']),
      students: studentList,

      address: json['address'],
      distanceTotal: _parseDouble(json['distance_total']),
      durationGoing: _parseInt(json['duration_going']),
      durationReturn: _parseInt(json['duration_return']),
    );
  }
}