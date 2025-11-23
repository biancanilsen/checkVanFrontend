import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../provider/forgot_password_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/van/custom_snackbar.dart';
import '../../../enum/snack_bar_type.dart';
import 'email_sent_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordPage({
    super.key,
    this.initialEmail,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(ForgotPasswordProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await provider.sendRecoveryEmail(email);

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailSentPage(email: email),
        ),
      );
    } else {
      CustomSnackBar.show(
        context: context,
        label: provider.error ?? 'Erro ao enviar e-mail.',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordProvider(),
      child: Consumer<ForgotPasswordProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF2F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          size: 40,
                          color: AppPalette.primary800,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.primary900,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Digite seu e-mail e enviaremos um link para redefinir sua senha',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Input
                      CustomTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        hint: 'Digite seu e-mail',
                        isRequired: true,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite seu e-mail';
                          }
                          if (!value.contains('@')) {
                            return 'Digite um e-mail válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : () => _submit(provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.primary800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Enviar link',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}