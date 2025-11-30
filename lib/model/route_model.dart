import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'student_model.dart';

class RouteStep {
  final String instruction;
  final LatLng endLocation;

  RouteStep({required this.instruction, required this.endLocation});

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final rawInstruction = json['html_instructions'] as String? ?? '';
    final cleanInstruction = rawInstruction.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return RouteStep(
      instruction: cleanInstruction,
      endLocation: LatLng(
        (json['end_location']?['lat'] ?? 0.0).toDouble(),
        (json['end_location']?['lng'] ?? 0.0).toDouble(),
      ),
    );
  }
}

class RouteData {
  final int teamId;
  final String tripType;
  final String encodedPolyline;
  final List<Student> students;
  final List<RouteStep> steps;
  final LatLng schoolLocation;
  final String schoolName;

  RouteData({
    required this.teamId,
    required this.tripType,
    required this.encodedPolyline,
    required this.students,
    required this.steps,
    required this.schoolLocation,
    required this.schoolName,
  });

  factory RouteData.fromJson(Map<String, dynamic> json, int teamIdArg, String tripTypeArg) {
    // CORREÇÃO: Lê 'students' (que contém todos) em vez de 'studentsGoing'
    var listSource = json['students'] ?? json['studentsGoing'];
    var studentList = (listSource as List? ?? [])
        .map((s) => Student.fromJson(s))
        .toList();

    List<RouteStep> allSteps = [];
    if (json['route'] != null && json['route']['legs'] is List) {
      for (var leg in (json['route']['legs'] as List)) {
        if (leg['steps'] is List) {
          allSteps.addAll((leg['steps'] as List)
              .map((stepJson) => RouteStep.fromJson(stepJson)));
        }
      }
    }

    double schoolLat = 0.0;
    double schoolLng = 0.0;
    String sName = "Escola";

    if (json['team'] != null && json['team']['school'] != null) {
      final schoolObj = json['team']['school'];

      schoolLat = (schoolObj['latitude'] ?? 0.0).toDouble();
      schoolLng = (schoolObj['longitude'] ?? 0.0).toDouble();
      sName = schoolObj['name'] ?? "Escola";
    }

    return RouteData(
      teamId: teamIdArg,
      tripType: tripTypeArg,
      encodedPolyline: json['route']?['overview_polyline']?['points'] ?? '',
      students: studentList,
      steps: allSteps,
      schoolLocation: LatLng(schoolLat, schoolLng),
      schoolName: sName,
    );
  }
}