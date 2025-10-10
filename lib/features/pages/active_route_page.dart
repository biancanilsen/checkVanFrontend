import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class ActiveRoutePage extends StatelessWidget {
  const ActiveRoutePage({super.key});

  // Widget auxiliar para cada item da lista de paradas
  Widget _buildStopTile({
    required String name,
    required String address,
    required bool isLastStop,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A "Linha do Tempo" com o pino e a linha vertical
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: AppPalette.red700, size: 28),
                if (!isLastStop)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppPalette.neutral300,
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Avatar e informações do aluno
          Expanded(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  // Imagem alterada para usar o asset local
                  backgroundImage: AssetImage('assets/retratoCrianca.webp'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(address, style: const TextStyle(color: AppPalette.neutral600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dados de exemplo
    final stops = [
      {'name': 'Estella Mello', 'address': 'Rua 15 de setembro, 345'},
      {'name': 'Luiz Augusto', 'address': 'Rua Rodolfo Scherer, 987'},
      {'name': 'Sofia Martins', 'address': 'Avenida Brasil, 1024'},
      {'name': 'Pedro Henrique', 'address': 'Rua das Palmeiras, 50'},
      {'name': 'Estella Mello', 'address': 'Rua 15 de setembro, 345'},
      {'name': 'Luiz Augusto', 'address': 'Rua Rodolfo Scherer, 987'},
      {'name': 'Sofia Martins', 'address': 'Avenida Brasil, 1024'},
      {'name': 'Pedro Henrique', 'address': 'Rua das Palmeiras, 50'},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/rota_gps.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: AppPalette.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text(
                      'Próximas paradas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.primary900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: stops.length,
                      itemBuilder: (context, index) {
                        final stop = stops[index];
                        // Adicionado Padding para criar o espaçamento vertical
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildStopTile(
                            name: stop['name']!,
                            address: stop['address']!,
                            isLastStop: index == stops.length - 1,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

