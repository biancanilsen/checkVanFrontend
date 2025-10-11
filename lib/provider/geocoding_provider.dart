import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/address_suggestion.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class GeocodingProvider extends ChangeNotifier {
  Timer? _debounce;

  Future<List<AddressSuggestion>> fetchSuggestions(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final completer = Completer<List<AddressSuggestion>>();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) {
        completer.complete([]);
        return;
      }

      try {
        final token = await UserSession.getToken();
        if (token == null) throw Exception('Usuário não autenticado.');

        final response = await http.get(
          Uri.parse('${Endpoints.autocompleteAddress}?input=${Uri.encodeComponent(query)}'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final suggestions = data.map((json) => AddressSuggestion.fromJson(json)).toList();
          completer.complete(suggestions);
        } else {
          completer.complete([]);
        }
      } catch (e) {
        print('Erro ao buscar sugestões de endereço: $e');
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
