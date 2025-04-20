import 'package:check_van_frontend/provider/login_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/pages/home_page.dart';
import 'features/pages/login_page.dart';
import 'features/pages/signup_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check Van',
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (_) => LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/home': (_) => const HomePage()
      },
    );
  }
}
