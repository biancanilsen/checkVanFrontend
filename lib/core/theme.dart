import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  static const Color primary900 = Color(0xFF101C2C);
  static const Color primary100 = Color(0xFFD2E0EC);
  static const Color secondary500 = Color(0xFFFFC532);

  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral75 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFCED6D9);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFAEB9BB);
  static const Color neutral500 = Color(0xFFA1A1AA);
  static const Color neutral600 = Color(0xFF7B8591);
  static const Color neutral900 = Color(0xFF212121);

  static const Color red500 = Color(0xFFD32F2F);
  static const Color green500 = Color(0xFF037D2C);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

class AppTheme {
  static ThemeData get theme {
    final textTheme = GoogleFonts.poppinsTextTheme();
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.primary900,         // Cor principal para elementos interativos
      onPrimary: AppPalette.white,           // Cor do conteúdo (texto/ícone) sobre a cor primária
      secondary: AppPalette.secondary500,     // Cor secundária
      onSecondary: AppPalette.black,         // Conteúdo sobre a cor secundária
      error: AppPalette.red500,              // Cor para erros
      onError: AppPalette.white,             // Conteúdo sobre a cor de erro
      background: AppPalette.white,          // Fundo principal do app
      onBackground: AppPalette.primary900,   // Conteúdo sobre o fundo principal
      surface: AppPalette.neutral100,        // Cor de superfície de cards, modais (seu cinzaClaro)
      onSurface: AppPalette.primary900,      // Conteúdo sobre as superfícies
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        filled: true,
        fillColor: AppPalette.neutral75,

        hintStyle: const TextStyle(
          color: AppPalette.neutral500,
          fontSize: 16,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.primary100, width: 1.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppPalette.neutral900, width: 1.0),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),

        labelStyle: const TextStyle(color: AppPalette.neutral600),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          minimumSize: const Size.fromHeight(40),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(34)),
          ),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(34),
              )
          ),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          elevation: MaterialStateProperty.all(4.0),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0, // Adiciona uma sombra
        contentTextStyle: const TextStyle(color: AppPalette.white, fontFamily: 'Poppins'),
      ),

      textTheme: textTheme.copyWith(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.neutral900),
        bodyLarge: TextStyle(color: AppPalette.neutral900),
        bodyMedium: TextStyle(color: AppPalette.neutral600),
        labelLarge: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}