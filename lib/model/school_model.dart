class School {
  final int id;
  final String name;
  final String? address;
  final String? morningLimit;
  final String? morningDeparture;
  final String? afternoonLimit;
  final String? afternoonDeparture;
  final double? latitude;
  final double? longitude;

  School({
    required this.id,
    required this.name,
    this.address,
    this.morningLimit,
    this.morningDeparture,
    this.afternoonLimit,
    this.afternoonDeparture,
    this.latitude,
    this.longitude,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nome da escola indisponível',
      address: json['address'],
      morningLimit: json['morning_limit'],
      morningDeparture: json['morning_departure'],
      afternoonLimit: json['afternoon_limit'],
      afternoonDeparture: json['afternoon_departure'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
