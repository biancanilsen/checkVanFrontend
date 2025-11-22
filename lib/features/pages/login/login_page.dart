import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../enum/snack_bar_type.dart';
import '../../../provider/forgot_password_provider.dart';
import '../../../provider/login_provider.dart';
import '../../../services/notification_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/login/forgot_password_modal.dart';
import '../../widgets/van/custom_snackbar.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  // Cor principal (Azul escuro do tema)
  final Color _primaryColor = const Color(0xFF0D3B66);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Image.asset(
                    'assets/children_login.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),

                Text(
                  'Bem-vindo',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: emailController,
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: passwordController,
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  isRequired: true,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // MUDANÇA AQUI: Navegação para a nova página
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                provider.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await provider.login(
                        emailController.text,
                        passwordController.text,
                      );
                      if (success && context.mounted) {
                        await NotificationService.registerToken();
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        CustomSnackBar.show(
                          context: context,
                          label: provider.error ?? 'Erro inesperado',
                          type: SnackBarType.error,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(color: AppPalette.primary900, fontSize: 14, fontWeight: FontWeight.w500 ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: AppPalette.primary800,
                          fontWeight: FontWeight.w500,
                          fontSize: 14
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}