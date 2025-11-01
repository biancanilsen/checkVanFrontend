import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/student_provider.dart';
import '../../../utils/user_session.dart';
import '../../widgets/home/driver_shell.dart';
import '../../widgets/home/guardian_shell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserSession.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Erro ao carregar usuário')),
          );
        } else {
          final user = snapshot.data!;
          final role = user.role;

          if (role == 'driver') {
            return ChangeNotifierProvider(
              create: (_) => StudentProvider(),
              child: const DriverShell(),
            );
          } else if (role == 'guardian') {
            return const GuardianShell();
          } else {
            return const Scaffold(
              body: Center(child: Text('Tipo de usuário desconhecido')),
            );
          }
        }
      },
    );
  }
}