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
  final String encodedPolyline;
  final List<Student> students; // Alunos confirmados para esta rota
  final List<RouteStep> steps;

  RouteData({
    required this.encodedPolyline,
    required this.students,
    required this.steps,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    // Extrai a lista de alunos que farão a viagem ('studentsGoing')
    var studentList = (json['studentsGoing'] as List? ?? [])
        .map((s) => Student.fromJson(s..['isConfirmed'] = true)) // Adiciona a flag de confirmado
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

    return RouteData(
      encodedPolyline: json['route']?['overview_polyline']?['points'] ?? '',
      students: studentList,
      steps: allSteps,
    );
  }
}

