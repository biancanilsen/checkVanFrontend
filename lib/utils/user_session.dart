import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/driver_model.dart';
import '../model/user_model.dart';

class UserSession {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  /// Salva o token de autenticação
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Retorna o token de autenticação ou `null` se não existir
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Salva os dados do usuário no cache em formato JSON
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, jsonString);
  }

  /// Retorna os dados do usuário armazenados ou `null` se não existir
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    if (jsonString == null) return null;
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserModel.fromJson(map);
  }

  /// Limpa token e dados do usuário (logout)
  static Future<void> signOutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
