import 'package:flutter/material.dart';

class AppColors {
  static const Color azulEscuro = Color(0xFF101C2C); // fundo principal
  static const Color amarelo = Color(0xFFFFC532);    // destaque
  static const Color azulClaro = Color(0xFF2EBBF2);  // realce
  static const Color cinza = Color(0xFF7B8591);      // texto secundário
  static const Color verdeSucesso = Color(0xFF27AE60); // feedback positivo
  static const Color cinzaClaro = Color(0xFFEEEEEE);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.azulEscuro,
        onPrimary: Colors.white,
        secondary: AppColors.amarelo,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: Colors.white,
        onBackground: AppColors.azulEscuro,
        surface: AppColors.cinzaClaro,
        onSurface: AppColors.azulEscuro,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azulEscuro,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        errorStyle: const TextStyle(height: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.amarelo,
          minimumSize: const Size.fromHeight(40),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.azulEscuro),
        bodyMedium: TextStyle(color: AppColors.cinza),
      ),
    );
  }
}
