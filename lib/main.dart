import 'dart:async';
import 'package:check_van_frontend/features/pages/error/server_error_page.dart';
import 'package:check_van_frontend/provider/notification_provider.dart';
import 'package:check_van_frontend/provider/van_tracking_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:check_van_frontend/services/notification_service.dart';
import 'package:check_van_frontend/services/navigation_service.dart';
import 'package:check_van_frontend/services/session_manager.dart';
import 'package:check_van_frontend/utils/user_session.dart';

import 'package:check_van_frontend/features/pages/route/active_route_page.dart';
import 'package:check_van_frontend/features/pages/route/route_page.dart';
import 'package:check_van_frontend/features/pages/school/school_page.dart';
import 'package:check_van_frontend/features/pages/team/add_team_page.dart';
import 'package:check_van_frontend/features/pages/van/add_van_page.dart';
import 'package:check_van_frontend/provider/geocoding_provider.dart';
import 'package:check_van_frontend/provider/login_provider.dart';
import 'package:check_van_frontend/provider/presence_provider.dart';
import 'package:check_van_frontend/provider/route_provider.dart';
import 'package:check_van_frontend/provider/school_provider.dart';
import 'package:check_van_frontend/provider/student_provider.dart';
import 'package:check_van_frontend/provider/team_provider.dart';
import 'package:check_van_frontend/provider/tripProvider.dart';
import 'package:check_van_frontend/provider/van_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/pages/student/add_student_page.dart';
import 'features/pages/home/home_page.dart';
import 'features/pages/login/login_page.dart';
import 'features/pages/profile/my_profile.dart';
import 'features/pages/school/add_school_page.dart';
import 'features/pages/login/signup_page.dart';
import 'features/pages/student/students_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initListeners();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => SchoolProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => GeocodingProvider()),
        ChangeNotifierProvider(create: (_) => VanProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => PresenceProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => VanTrackingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isLogged = false;
  late StreamSubscription _sessionExpiredSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupSessionListener();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionExpiredSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("🚀 App retornou do background. Verificando validade do token...");
      SessionManager().checkTokenValidity();
    }
  }

  void _setupSessionListener() {
    _sessionExpiredSubscription = SessionManager().onSessionExpired.listen((_) {
      print("🛑 Sessão expirada detectada (Main). Redirecionando...");

      if (!mounted) return;

      if (navigatorKey.currentState == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        });
      } else {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      }

      setState(() {
        _isLogged = false;
      });
    });
  }

  Future<void> _checkLoginStatus() async {
    final token = await UserSession.getToken();
    final user = await UserSession.getUser();

    if (token != null && user != null) {
      print("🚀 App Iniciado: Usuário logado detectado. Iniciando SessionManager...");
      SessionManager().startSession();

      if (mounted) {
        setState(() {
          _isLogged = true;
        });
      }
    } else {
      SessionManager().stopSession();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      title: 'Check Van',
      theme: AppTheme.theme,
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_isLogged ? const HomePage() : const LoginPage()),

      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/home': (_) => const HomePage(),
        '/my_profile': (context) => const Scaffold(
          body: SafeArea(
            child: MyProfile(),
          ),
        ),
        '/students': (context) => const StudentPage(),
        '/add-student': (context) => const AddStudentPage(),
        '/add-van': (context) => const AddVanPage(),
        '/schools': (context) => const SchoolPage(),
        '/add-school': (context) => const AddSchoolPage(),
        '/route': (context) => const RoutePage(),
        '/active-route': (context) => const ActiveRoutePage(),
        '/add-team': (context) => const AddTeamPage(),
        '/server-error': (context) => const ServerErrorPage(),
      },
    );
  }
}