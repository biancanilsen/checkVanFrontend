import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'student_model.dart'; // Certifique-se que este import está correto

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
  final int teamId; // <-- 1. CAMPO ADICIONADO
  final String tripType; // <-- 2. ADICIONADO (Ex: "GOING" ou "RETURNING")
  final String encodedPolyline;
  final List<Student> students; // Alunos confirmados para esta rota
  final List<RouteStep> steps;
  final LatLng schoolLocation;
  final String schoolName;

  RouteData({
    required this.teamId, // <-- 3. ADICIONADO AO CONSTRUTOR
    required this.tripType, // <-- 4. ADICIONADO AO CONSTRUTOR
    required this.encodedPolyline,
    required this.students,
    required this.steps,
    required this.schoolLocation,
    required this.schoolName,
  });

  // --- 5. FÁBRICA ATUALIZADA ---
  // Agora ela recebe o teamId e o tripType de quem a está chamando
  factory RouteData.fromJson(Map<String, dynamic> json, int teamId, String tripType) {
    var studentList = (json['studentsGoing'] as List? ?? [])
        .map((s) => Student.fromJson(s..['isConfirmed'] = true))
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

    // Extrai os dados da escola do JSON (assumindo que a API os envia)
    final schoolData = json['school'] as Map<String, dynamic>? ?? {};
    final schoolLat = (schoolData['latitude'] ?? 0.0).toDouble();
    final schoolLng = (schoolData['longitude'] ?? 0.0).toDouble();
    final schoolName = schoolData['name'] as String? ?? 'Escola';

    return RouteData(
      teamId: teamId, // <-- 6. PASSADO
      tripType: tripType, // <-- 7. PASSADO
      encodedPolyline: json['route']?['overview_polyline']?['points'] ?? '',
      students: studentList,
      steps: allSteps,
      schoolLocation: LatLng(schoolLat, schoolLng),
      schoolName: schoolName,
    );
  }
}