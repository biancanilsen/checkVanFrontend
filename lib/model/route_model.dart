import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'student_model.dart'; // Certifique-se que este import está correto

/// Representa um único passo ou manobra na navegação (ex: "Vire à direita").
class RouteStep {
  final String instruction;
  final LatLng endLocation;

  RouteStep({required this.instruction, required this.endLocation});

  /// Cria um RouteStep a partir de um mapa JSON (um 'step' da API do Google).
  factory RouteStep.fromJson(Map<String, dynamic> json) {
    // A instrução vem com tags HTML (<b>, <div>), que precisamos remover.
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

/// O modelo principal que contém todos os dados de uma rota gerada.
class RouteData {
  final String encodedPolyline;
  final List<Student> students;
  final List<RouteStep> steps; // A lista de instruções passo a passo.

  RouteData({
    required this.encodedPolyline,
    required this.students,
    required this.steps,
  });

  /// Cria um objeto RouteData a partir do JSON completo retornado pelo seu backend.
  factory RouteData.fromJson(Map<String, dynamic> json) {
    // Extrai a lista de alunos que farão a viagem.
    var studentList = (json['studentsGoing'] as List? ?? [])
        .map((s) => Student.fromJson(s))
        .toList();

    // A API do Google retorna "legs" (percursos entre paradas).
    // Vamos juntar todos os "steps" de todas as "legs" em uma única lista de instruções.
    List<RouteStep> allSteps = [];
    if (json['route'] != null && json['route']['legs'] is List) {
      for (var leg in (json['route']['legs'] as List)) {
        if (leg['steps'] is List) {
          var legSteps = (leg['steps'] as List)
              .map((stepJson) => RouteStep.fromJson(stepJson))
              .toList();
          allSteps.addAll(legSteps);
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

