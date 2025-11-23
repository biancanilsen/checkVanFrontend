import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/endpoints.dart';
import '../utils/user_session.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Timer? _refreshTimer;

  void startSession() {
    _stopTimer();

    const refreshInterval = Duration(minutes: 50);

    _refreshTimer = Timer.periodic(refreshInterval, (timer) async {
      await _renewToken();
    });
  }

  void stopSession() {
    _stopTimer();
  }

  void _stopTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _renewToken() async {
    try {
      final currentToken = await UserSession.getToken();
      if (currentToken == null) {
        stopSession();
        return;
      }

      final response = await http.post(
        Uri.parse(Endpoints.refreshToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final newToken = body['token'];

        if (newToken != null) {
          await UserSession.saveToken(newToken);
        }
      } else {
        // Opcional: Se falhar (ex: 401 ou 403), pode forçar logout aqui
      }
    } catch (e) {
    }
  }
}