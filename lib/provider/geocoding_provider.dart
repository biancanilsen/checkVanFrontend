import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/address_suggestion.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';
import '../services/navigation_service.dart';

class GeocodingProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();
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

        final response = await _client.get(
          Uri.parse('${Endpoints.autocompleteAddress}?input=${Uri.encodeComponent(query)}'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 15)); // Timeout curto para autocomplete

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final suggestions = data.map((json) => AddressSuggestion.fromJson(json)).toList();
          completer.complete(suggestions);
        } else {
          completer.complete([]);
        }
      } on TimeoutException catch (_) {
        NavigationService.forceErrorScreen();
        completer.complete([]);
      } on SocketException catch (_) {
        NavigationService.forceErrorScreen();
        completer.complete([]);
      } catch (e) {
        print('Erro ao buscar sugestões de endereço: $e');
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  Future<Map<String, double>> getPlaceDetails(String placeId) async {
    try {
      final token = await UserSession.getToken();
      if (token == null) {
        throw Exception('Usuário não autenticado.');
      }

      final response = await http.get(
        Uri.parse('${Endpoints.geocodingDetails}?placeId=${Uri.encodeComponent(placeId)}'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dynamic latRaw = data['lat'] ?? data['latitude'];
        final dynamic lonRaw = data['lon'] ?? data['lng'] ?? data['longitude'];

        if (latRaw is! num || lonRaw is! num) {
          throw Exception('Coordenadas inválidas retornadas pelo serviço de geocodificação.');
        }
        return {'lat': latRaw.toDouble(), 'lon': lonRaw.toDouble()};
      } else {
        throw Exception('Falha ao obter detalhes do local.');
      }
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
      rethrow;
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
      rethrow;
    } catch (e) {
      debugPrint('Erro ao obter detalhes do local: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}