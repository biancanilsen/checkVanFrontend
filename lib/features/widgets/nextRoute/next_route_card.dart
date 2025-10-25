// lib/widgets/next_route_card.dart

import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

// 1. ADICIONE OS IMPORTS NECESSÁRIOS
import 'package:provider/provider.dart';
import 'package:check_van_frontend/provider/route_provider.dart';
// (O import do route_provider.dart pode precisar de ajuste no caminho)

class NextRouteCard extends StatelessWidget {
  // 2. ADICIONE O teamId, IGUAL AO HomeRouteCard
  final int teamId;

  const NextRouteCard({
    super.key,
    required this.teamId, // Torne-o obrigatório
  });

  @override
  Widget build(BuildContext context) {
    // 3. OBTENHA O PROVIDER
    final routeProvider = context.watch<RouteProvider>();

    const double cardHeight = 265;
    const double mapVisibilityRatio = 0.3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 1.0,
        shadowColor: Colors.black.withOpacity(0.1),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // Camada 1: Fundo com o mapa
            Container(
              height: cardHeight,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/rota.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Camada 2: O CONTEÚDO (título, infos, botão)
            Container(
              height: cardHeight, // Ocupa a altura total do Card
              padding: EdgeInsets.fromLTRB(
                12,
                (cardHeight * mapVisibilityRatio) + 12,
                12,
                12,
              ),
              child: Column(
                children: [
                  // Título da Rota (Topo, Centralizado)
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wb_sunny_outlined,
                            size: 18, color: Colors.black87),
                        SizedBox(width: 8),
                        Text(
                          'Rota da manhã',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Linha de informações: Alunos (esq) / Início + chip (dir)
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
                            child: const Text(
                              // Como não temos mais routeData,
                              // voltamos ao valor estático
                              // (ou você pode buscar isso de outro lugar)
                              '12',
                              style: TextStyle(
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
                          const Text(
                            'Início',
                            style: TextStyle(
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
                              color: AppPalette.orange100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Em 5 min',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppPalette.orange700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Botão "Iniciar rota"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      // 4. SUBSTITUA O onPressed PELA LÓGICA DO HomeRouteCard
                      onPressed: routeProvider.isLoading
                          ? null // Desabilita o botão se estiver carregando
                          : () async {
                        final success = await routeProvider.generateRoute(
                          teamId: teamId, // Usa o teamId passado
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      // 5. ADICIONE O INDICADOR DE LOADING NO BOTÃO
                      child: routeProvider.isLoading
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