import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PendingConfirmationCallout extends StatelessWidget {
  const PendingConfirmationCallout({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // O widget principal agora é uma Column
    return Column(
      children: [
        // 1. A IMAGEM
        // Fica fora do container de aviso
        Image.asset(
          'assets/school_bus.png', // Imagem da captura de tela
          height: 200, // Você pode ajustar esta altura
          width: double.infinity,
          // BoxFit.contain garante que a ilustração inteira apareça
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 16), // Espaço entre a imagem e o card

        // 2. O CARD DE AVISO
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppPalette.yellow200, // Cor da borda
              width: 1.5, // Largura da borda
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Alinha verticalmente
            children: [
              SvgPicture.asset(
                'assets/icons/warning_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppPalette.yellow200,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirme a presença da rota de amanhã!',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppPalette.neutral900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}