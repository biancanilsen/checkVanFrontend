import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/country_model.dart';
import '../network/endpoints.dart'; // Adicione a constante countries no seu arquivo Endpoints

class UtilService {
  static Future<List<CountryModel>> getCountries() async {
    try {
      // Certifique-se de adicionar: static const String countries = '$baseUrl/utils/countries'; no Endpoints
      final response = await http.get(Uri.parse(Endpoints.getCountries));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CountryModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao buscar países: $e');
    }
    // Fallback caso a API falhe (Padrão Brasil)
    return [
      CountryModel(name: 'Brasil', code: 'BR', dialCode: '+55', mask: '(##) #####-####', minLength: 11)
    ];
  }
}