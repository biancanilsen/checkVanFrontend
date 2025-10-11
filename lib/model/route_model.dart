import 'package:check_van_frontend/model/student_model.dart';

class Waypoint {
  final double lat;
  final double lon;
  final String? name;

  Waypoint({required this.lat, required this.lon, this.name});
}

class RouteData {
  final List<Student> students;
  final List<Waypoint> waypoints;
  // Você pode adicionar outros campos que a API de rota retornar,
  // como a linha do trajeto (polyline), distância, duração, etc.

  RouteData({required this.students, required this.waypoints});
}