import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/student_provider.dart';
import '../../../utils/user_session.dart';
import '../../widgets/home/driver_shell.dart';
import '../../widgets/home/guardian_shell.dart';
import '../profile/reset_password_page.dart'; // Importe a nova tela

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    // Verifica a senha temporária logo após a tela ser montada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTempPassword();
    });
  }

  Future<void> _checkTempPassword() async {
    final user = await UserSession.getUser();
    // Se o campo isTempPassword for true, mostra a modal
    if (user != null && user.isTempPassword) {
      _showTempPasswordModal();
    }
  }

  void _showTempPasswordModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede sair clicando fora
      builder: (context) {
        // Intercepta o botão "Voltar" do Android
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Altere sua senha", textAlign: TextAlign.start, style: TextStyle(color: AppPalette.primary900)),
            content: const Text(
              "Você acessou com uma senha temporária. Para a segurança de seus dados, crie uma nova senha.",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // "Mais tarde"
                child: const Text("Mais tarde", style: TextStyle(color: AppPalette.neutral700, fontWeight: FontWeight.w500)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha modal
                  // Vai para a tela de redefinição
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ResetPasswordPage())
                  );
                },
                child: const Text("Alterar senha", style: TextStyle(color: AppPalette.primary800, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        );
      },
    );
  }

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