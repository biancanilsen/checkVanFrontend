import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/user_session.dart';
import '../services/session_manager.dart';

class ApiClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. INTERCEPTOR DE REQUISIÇÃO
    // Adiciona o token automaticamente em todas as chamadas
    final token = await UserSession.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Garante Content-Type JSON se não estiver definido
    if (!request.headers.containsKey('Content-Type')) {
      request.headers['Content-Type'] = 'application/json';
    }

    // Envia a requisição original
    final streamedResponse = await _inner.send(request);

    // 2. INTERCEPTOR DE RESPOSTA
    // Verifica globalmente se o token expirou (401 ou 403)
    if (streamedResponse.statusCode == 401 || streamedResponse.statusCode == 403) {
      // Evita loop infinito se o erro vier do próprio endpoint de refresh
      if (!request.url.path.contains('refresh-token')) {
        print("🛑 ApiClient: Erro ${streamedResponse.statusCode} na rota ${request.url.path}. Expirando sessão...");
        SessionManager().expireSession();
      }
    }

    return streamedResponse;
  }
}