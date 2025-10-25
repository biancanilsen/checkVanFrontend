import 'package:flutter/material.dart';
import '../../../utils/user_session.dart';
import 'home_guardian.dart';
import 'home_driver.dart';

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
            return const HomeDriver();
          } else if (role == 'guardian') {
            return const HomeGuardian();
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
