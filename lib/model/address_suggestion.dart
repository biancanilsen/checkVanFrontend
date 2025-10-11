class AddressSuggestion {
  final String displayName;
  final String addressDetails;
  final String placeId;
  final String fullDescription;

  AddressSuggestion({
    required this.displayName,
    required this.addressDetails,
    required this.placeId,
    required this.fullDescription,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    final fullDescription = json['description'] as String? ?? 'Local desconhecido';

    String displayName;
    String addressDetails;

    if (fullDescription.contains(' - ')) {
      final parts = fullDescription.split(' - ');
      displayName = parts.first;
      addressDetails = parts.sublist(1).join(' - ');
    } else {
      displayName = fullDescription;
      addressDetails = '';
    }

    return AddressSuggestion(
      displayName: displayName,
      addressDetails: addressDetails,
      placeId: json['placeId'] as String? ?? '',
      fullDescription: fullDescription,
    );
  }
}