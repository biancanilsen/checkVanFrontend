import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ServerErrorPage extends StatelessWidget {
  const ServerErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícone ou Imagem
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppPalette.red500.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 80,
                  color: AppPalette.red500,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                "Ops! Algo deu errado.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.primary900,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Não conseguimos conectar ao servidor.\nPode ser um problema na sua internet ou nossos serviços estão em manutenção.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Tenta voltar para a tela anterior (o que forçará o usuário a tentar a ação de novo)
                    // Ou redireciona para a Home/Login
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // Se não tiver para onde voltar, vai para o início
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tentar Novamente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}