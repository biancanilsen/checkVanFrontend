import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:check_van_frontend/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../utils/user_session.dart';
import '../services/navigation_service.dart';

class SignUpProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  bool isLoading = false;
  String? error;

  Future<bool> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String birthDate,
    String? driverLicense,
    String? phoneCountry,
  }) async {
    isLoading = true;
    notifyListeners();

    final body = {
      'name': name,
      'phone': phone,
      'phone_country': phoneCountry,
      'email': email,
      'password': password,
      'role': driverLicense != null ? 'driver' : 'guardian',
      'driver_license': driverLicense,
      'birth_date': birthDate,
    };

    try {
      final response = await _client.post(
        Uri.parse(Endpoints.userRegistration),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final int userId = data['userId'];

        final user = UserModel(
          id: userId,
          name: name,
          phone: phone,
          phoneCountry: phoneCountry,
          email: email,
          role: driverLicense != null ? 'driver' : 'guardian',
          driverLicense: driverLicense,
          birthDate: DateTime.parse(birthDate),
        );

        await UserSession.saveUser(user);
        error = null;
        return true;
      } else {
        final data = jsonDecode(response.body);
        error = data['message'] ?? 'Erro no cadastro';
        return false;
      }
    } on TimeoutException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } on SocketException catch (_) {
      NavigationService.forceErrorScreen();
      return false;
    } catch (e) {
      error = 'Erro de conexão';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}