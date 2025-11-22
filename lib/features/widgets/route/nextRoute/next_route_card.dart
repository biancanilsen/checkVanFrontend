import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:check_van_frontend/provider/route_provider.dart';

import '../../../../../model/trip_model.dart'; // Import o novo model

class NextRouteCard extends StatelessWidget {
  // Recebe o objeto Trip, que pode ser nulo se não houver próxima viagem
  final Trip? nextTrip;

  const NextRouteCard({
    super.key,
    this.nextTrip, // <--- Parâmetro 'nextTrip'
  });

  @override
  Widget build(BuildContext context) {
    // Lê o RouteProvider (para o botão de Iniciar)
    final routeProvider = context.read<RouteProvider>();
    // Observa o RouteProvider (para o estado de loading do botão)
    final routeProviderLoading = context.watch<RouteProvider>().isLoading;

    const double cardHeight = 265;
    const double mapVisibilityRatio = 0.3;

    // --- LÓGICA DE DADOS ---
    final bool hasTrip = nextTrip != null;
    final int? teamId = nextTrip?.teamId;
    final String rota = nextTrip?.rota ?? 'Nenhuma rota futura';
    final String alunos = nextTrip?.quantidadeAlunos.toString() ?? '0';
    final String comecaEm = nextTrip?.comecaEm ?? '--';
    final String horario = nextTrip?.horarioInicio ?? '--';
    final IconData icon = nextTrip?.tipo == 'Ida'
        ? Icons.wb_sunny_outlined
        : Icons.brightness_6_outlined;
    final Color chipBgColor = nextTrip?.tipo == 'Ida'
        ? AppPalette.orange100
        : AppPalette.primary50;
    final Color chipTextColor = nextTrip?.tipo == 'Ida'
        ? AppPalette.orange700
        : AppPalette.primary900;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 1.0,
        shadowColor: Colors.black.withOpacity(0.1),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Container(
              height: cardHeight,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/rota.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: cardHeight,
              padding: EdgeInsets.fromLTRB(
                12,
                (cardHeight * mapVisibilityRatio) + 12,
                12,
                12,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasTrip) ...[
                          Icon(icon, size: 18, color: Colors.black87),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          rota,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alunos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              alunos,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hasTrip ? 'Início ($horario)' : 'Início',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                              hasTrip ? chipBgColor : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              comecaEm,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: hasTrip
                                    ? chipTextColor
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (routeProviderLoading || !hasTrip)
                          ? null
                          : () async {
                        final success = await routeProvider.generateRoute(
                          teamId: teamId!,
                            tripType: "GOING" // todo - remover informação mock
                        );
                        if (success && context.mounted) {
                          Navigator.pushNamed(
                            context,
                            '/route',
                            arguments: routeProvider.routeData,
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(routeProvider.error ??
                                  'Erro ao gerar rota'),
                              backgroundColor: AppPalette.red500,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary800,
                        foregroundColor: AppPalette.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: routeProviderLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: AppPalette.white,
                          strokeWidth: 3,
                        ),
                      )
                          : const Text(
                        'Iniciar rota',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}