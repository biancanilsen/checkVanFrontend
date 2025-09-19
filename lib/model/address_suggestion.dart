// lib/model/address_suggestion.dart

class AddressSuggestion {
  final String displayName;
  final String city;
  final String state;
  final String country;
  final double lat;
  final double lon;

  AddressSuggestion({
    required this.displayName,
    required this.city,
    required this.state,
    required this.country,
    required this.lat,
    required this.lon,
  });

  // Constrói a string de detalhes a partir dos campos separados
  String get addressDetails => [city, state, country].where((s) => s.isNotEmpty).join(', ');

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    return AddressSuggestion(
      displayName: json['display_name'] ?? 'Local desconhecido',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
    );
  }
}