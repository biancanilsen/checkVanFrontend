// lib/model/address_suggestion.dart

class AddressSuggestion {
  final String displayName;
  final String addressDetails;
  final String placeId;

  // Campos que vamos extrair depois de selecionar um endereço
  final String? city;
  final String? state;
  final String? country;
  final double? lat;
  final double? lon;

  AddressSuggestion({
    required this.displayName,
    required this.addressDetails,
    required this.placeId,
    this.city,
    this.state,
    this.country,
    this.lat,
    this.lon,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    final fullDescription = json['description'] as String? ?? 'Local desconhecido';

    // 2. Divide a descrição para criar um título e um subtítulo.
    //    Ex: "Rua Alberto Cintra - União, Belo Horizonte - MG, Brasil"
    //    displayName   -> "Rua Alberto Cintra"
    //    addressDetails -> "União, Belo Horizonte - MG, Brasil"
    String displayName;
    String addressDetails;

    if (fullDescription.contains(' - ')) {
      final parts = fullDescription.split(' - ');
      displayName = parts.first; // A primeira parte é o nome da rua
      addressDetails = parts.sublist(1).join(' - '); // O resto é o detalhe
    } else {
      // Se não tiver ' - ', usa a descrição toda como título e deixa os detalhes vazios.
      displayName = fullDescription;
      addressDetails = '';
    }

    return AddressSuggestion(
      displayName: displayName,
      addressDetails: addressDetails,
      // Pega o placeId diretamente do JSON.
      placeId: json['placeId'] as String? ?? '',
    );
  }
}