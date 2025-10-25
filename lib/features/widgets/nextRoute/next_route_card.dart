import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class NextRouteCard extends StatelessWidget {
  const NextRouteCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos a altura total aqui para reutilizar
    const double cardHeight = 265;
    // Definimos a proporção visível do mapa (30% superior)
    const double mapVisibilityRatio = 0.3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        // Todo - rever essa borda por conta da imagem
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
              // Padding TOP ajustado
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
                            // Padding na base para alinhar com o chip
                            padding: const EdgeInsets.only(bottom: 6),
                            child: const Text(
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

                      // Direita: Início + chip "Em 5 min"
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

                  const Spacer(), // <-- Garante que o botão vá para baixo (sem overflow)

                  // Botão "Iniciar rota"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Ação de "Iniciar rota"
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
                      child: const Text(
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