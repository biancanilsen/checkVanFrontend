import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/forgot_password_provider.dart';
import '../../../provider/login_provider.dart';
import '../../widgets/login/forgot_password_modal.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo_check_van.png', height: 120),
              const SizedBox(height: 24),
              const Text(
                'Entre na sua conta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ForgotPasswordProvider(),
                        child: const ForgotPasswordModal(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    'Esqueci a senha',
                    style: TextStyle(
                      color: Color(0xFF0000EE),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              provider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  final success = await provider.login(
                    emailController.text,
                    passwordController.text,
                  );
                  if (success && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.error ?? 'Erro inesperado')),
                    );
                  }
                },
                child: const Text('Entrar'),
              ),

              const SizedBox(height: 16),

              provider.isLoading
                  ? const SizedBox.shrink()
                  : SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('Criar conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}