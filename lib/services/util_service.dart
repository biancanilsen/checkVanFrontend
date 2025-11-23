import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/country_model.dart';
import '../network/endpoints.dart';

class UtilService {
  static Future<List<CountryModel>> getCountries() async {
    try {
      final response = await http.get(Uri.parse(Endpoints.getCountries));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CountryModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao buscar países: $e');
    }
    return [
      CountryModel(name: 'Brasil', code: 'BR', dialCode: '+55', mask: '(##) #####-####', minLength: 11)
    ];
  }
}