import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/pages/home_page.dart';
import 'features/pages/login_page.dart';
import 'features/pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check Van',
      theme: AppTheme.theme,
      // 👇 Certifique-se que essa rota realmente existe
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/home': (_) => const HomePage()
      },
    );
  }
}
