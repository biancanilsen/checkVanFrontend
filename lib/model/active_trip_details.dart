import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActiveTripDetails {
  final int teamId;
  final String teamName;
  final LatLng studentLocation;
  final String? vanLocationLink; // TODO - link de rastreamento se precisar

  ActiveTripDetails({
    required this.teamId,
    required this.teamName,
    required this.studentLocation,
    this.vanLocationLink,
  });

  factory ActiveTripDetails.fromJson(Map<String, dynamic> json) {
    return ActiveTripDetails(
      teamId: json['teamId'] as int,
      teamName: json['teamName'] as String,
      studentLocation: LatLng(
        json['studentLat'] as double,
        json['studentLon'] as double,
      ),
      vanLocationLink: json['vanLocationLink'] as String?,
    );
  }
}