// Imports do Firebase
import 'package:check_van_frontend/provider/notification_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Você PRECISA deste arquivo (gerado pelo FlutterFire)

// Import do seu serviço de notificação
import 'package:check_van_frontend/services/notification_service.dart';
// --- ADICIONE O IMPORT DA NOVA CHAVE ---
import 'package:check_van_frontend/services/navigation_service.dart';

// Imports do seu app (existentes)
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
      initialRoute: '/',
      routes: {
        '/': (_) => LoginPage(),
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
      },
    );
  }
}