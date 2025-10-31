import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  static const Color primary900 = Color(0xFF101C2C); // #101C2C
  static const Color primary800 = Color(0xFF03467D); // #03467D
  static const Color primary100 = Color(0xFFD2E0EC); // #D2E0EC
  static const Color primary50 = Color(0xFFDBE9F4); // #DBE9F4
  static const Color secondary500 = Color(0xFFFFC532); // #FFC532

  static const Color neutral50 = Color(0xFFFAFAFA); // #FAFAFA
  static const Color neutral60 = Color(0xFFFEFEFE); // #FEFEFE
  static const Color neutral70 = Color(0xFFFDFDFD); // #FDFDFD
  static const Color neutral75 = Color(0xFFFAFAFA); // #FAFAFA
  static const Color neutral100 = Color(0xFFF5F5F5); // #F5F5F5
  static const Color neutral150 = Color(0xFFEFEFEF); // #EFEFEF
  static const Color neutral200 = Color(0xFFCED6D9); // #CED6D9
  static const Color neutral300 = Color(0xFFE0E0E0); // #E0E0E0
  static const Color neutral400 = Color(0xFFAEB9BB); // #AEB9BB
  static const Color neutral500 = Color(0xFFA1A1AA); // #A1A1AA
  static const Color neutral600 = Color(0xFF7B8591); // #7B8591
  static const Color neutral7De00 = Color(0xFF515151); // #515151
  static const Color neutral800 = Color(0xFF313131); // #313131
  static const Color neutral900 = Color(0xFF212121); // #212121

  static const Color red500 = Color(0xFFD32F2F); // #D32F2F
  static const Color red700 = Color(0xFFBF360C); // #BF360C

  static const Color green500 = Color(0xFF037D2C); // #037D2C
  static const Color green600 = Color(0xFF206820); // #206820

  static const Color orange700 = Color(0xFFC45F00); // #C45F00
  static const Color orange100 = Color(0xFFFFE0C3); // #FFE0C3

  static const Color white = Color(0xFFFFFFFF); // #FFFFFF
  static const Color black = Color(0xFF000000); // #000000

  static const Color appBackground = Color(0xFFF5F6F8); // #F5F6F8
}

class AppTheme {
  static ThemeData get theme {
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme();

    final baseTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppPalette.primary900,
        onPrimary: AppPalette.white,
        secondary: AppPalette.secondary500,
        onSecondary: AppPalette.black,
        error: AppPalette.red500,
        onError: AppPalette.white,
        surface: AppPalette.appBackground,
        onSurface: AppPalette.primary900,
      ),
      scaffoldBackgroundColor: AppPalette.appBackground,
      textTheme: poppinsTextTheme,
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.copyWith(
        titleLarge: poppinsTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppPalette.neutral900,
        ),
        bodyLarge: poppinsTextTheme.bodyLarge?.copyWith(
          color: AppPalette.neutral900,
        ),
        bodyMedium: poppinsTextTheme.bodyMedium?.copyWith(
          color: AppPalette.neutral600,
        ),
        labelLarge: poppinsTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ).apply(
        fontFamily: 'Poppins',
        bodyColor: AppPalette.neutral800,
        displayColor: AppPalette.neutral900,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: baseTheme.colorScheme.primary,
        foregroundColor: baseTheme.colorScheme.onPrimary,
        titleTextStyle: poppinsTextTheme.titleLarge?.copyWith(
          color: AppPalette.primary900,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        toolbarTextStyle: poppinsTextTheme.bodyMedium?.copyWith(
          color: AppPalette.primary900,
        ),
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
          borderSide: BorderSide(color: baseTheme.colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: baseTheme.colorScheme.error, width: 1.0),
        ),
        labelStyle: const TextStyle(color: AppPalette.neutral600),
        floatingLabelStyle: TextStyle(color: baseTheme.colorScheme.primary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseTheme.colorScheme.secondary,
          foregroundColor: baseTheme.colorScheme.onSecondary,
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
        elevation: 4.0,
        contentTextStyle: const TextStyle(color: AppPalette.white, fontFamily: 'Poppins'),
      ),
    );
  }
}
