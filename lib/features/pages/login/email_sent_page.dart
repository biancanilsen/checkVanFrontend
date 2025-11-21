import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../provider/forgot_password_provider.dart';
import '../../widgets/van/custom_snackbar.dart';
import '../../../enum/snack_bar_type.dart';

class EmailSentPage extends StatelessWidget {
  final String email;

  const EmailSentPage({super.key, required this.email});

  void _resendEmail(BuildContext context) async {
    // Aqui criamos uma instância temporária do provider apenas para a ação de reenviar,
    // ou você pode passar o provider da tela anterior se preferir.
    final provider = ForgotPasswordProvider();

    // Mostra loading visual simples ou snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reenviando e-mail...')),
    );

    final success = await provider.sendRecoveryEmail(email);

    if (context.mounted) {
      if (success) {
        CustomSnackBar.show(
          context: context,
          label: 'E-mail reenviado com sucesso!',
          type: SnackBarType.success,
        );
      } else {
        CustomSnackBar.show(
          context: context,
          label: 'Erro ao reenviar e-mail.',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Ícone de Sucesso
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEBF2F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 50,
                color: AppPalette.primary800,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'E-mail Enviado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary900,
              ),
            ),
            const SizedBox(height: 16),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: AppPalette.primary900, height: 1.5),
                children: [
                  const TextSpan(text: 'Enviamos uma nova senha temporária para \n'),
                  TextSpan(
                    text: email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppPalette.primary800,
                    ),
                  ),
                  const TextSpan(
                      text: '\n\nNão esqueça de verificar sua caixa de entrada e spam.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.primary900,
                      ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Botão Voltar ao Login
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // Volta até a primeira rota (Login)
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Voltar ao login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botão Reenviar E-mail
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => _resendEmail(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.primary800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined, color: AppPalette.primary800),
                    SizedBox(width: 8),
                    Text(
                      'Reenviar e-mail',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.primary800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}