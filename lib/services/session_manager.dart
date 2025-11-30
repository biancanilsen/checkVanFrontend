import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Timer? _refreshTimer;

  final StreamController<void> _logoutController = StreamController<void>.broadcast();
  Stream<void> get onSessionExpired => _logoutController.stream;

  void startSession() {
    _stopTimer();

    _renewToken();

    const refreshInterval = Duration(minutes: 50);
    _refreshTimer = Timer.periodic(refreshInterval, (timer) async {
      await _renewToken();
    });
  }

  void stopSession() {
    _stopTimer();
  }

  void expireSession() {
    if (kDebugMode) print("SessionManager: expireSession chamado externamente.");
    _forceLogout();
  }

  void _stopTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Verifica se o token é válido chamando o backend.
  /// Útil para quando o app volta do background (resume).
  Future<bool> checkTokenValidity() async {
    return await _renewToken();
  }

  Future<bool> _renewToken() async {
    try {
      final currentToken = await UserSession.getToken();
      if (currentToken == null) {
        return false;
      }

      if (kDebugMode) print("SessionManager: Verificando validade do token...");

      final response = await http.post(
        Uri.parse(Endpoints.refreshToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final newToken = body['token'];

        if (newToken != null) {
          await UserSession.saveToken(newToken);
          if (kDebugMode) {
            print("SessionManager: Token renovado com sucesso.");
          }
          return true;
        }
      } else {
        if (kDebugMode) print("SessionManager: Falha na renovação. Status: ${response.statusCode}");

        // Se o próprio refresh falhar com erro de autenticação, forçamos logout
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _forceLogout();
          return false;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("SessionManager: Erro de conexão ao renovar token: $e");
      }
    }
    return true;
  }

  Future<void> _forceLogout() async {
    if (kDebugMode) print("SessionManager: Executando _forceLogout e notificando listeners...");

    stopSession();
    await UserSession.signOutUser();

    _logoutController.add(null);
  }
}