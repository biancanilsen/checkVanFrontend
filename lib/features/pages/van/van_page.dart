import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import '../../widgets/van/van_tile.dart';

final mockVans = [
  {
    'name': 'Ducato Wesley',
    'model': 'Pegout Ducato',
    'plate': 'CHYt56',
  },
  {
    'name': 'Sprinter Branca',
    'model': 'Mercedes Sprinter',
    'plate': 'BRA2E19',
  },
];

class VanPage extends StatelessWidget {
  const VanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SEM SCAFFOLD
    return SafeArea(
      child: Stack( // Usamos Stack para o botão "+ Nova van" ficar fixo
        children: [
          // 1. Conteúdo que rola (Header, Busca, Lista)
          ListView(
            // Padding para o conteúdo não ser coberto pelo botão
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            children: [
              // Header "Minhas vans" (sem a seta de voltar)
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Text(
                  'Minhas vans',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Barra de Busca
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar modelo ou placa',
                    suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    filled: true,
                    fillColor: AppPalette.neutral70, // Cor do card
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),

              // Card que agrupa os itens da lista
              Card(
                color: AppPalette.neutral70,
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    // 2. USE O NOVO WIDGET AQUI
                    VanTile(
                      name: mockVans[0]['name']!,
                      model: mockVans[0]['model']!,
                      plate: mockVans[0]['plate']!,
                      onTap: () { /* Ação "Ver detalhes da van" */ },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
                    // E AQUI
                    VanTile(
                      name: mockVans[1]['name']!,
                      model: mockVans[1]['model']!,
                      plate: mockVans[1]['plate']!,
                      onTap: () { /* Ação "Ver detalhes da van" */ },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Botão Fixo "+ Nova van"
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nova van', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Navega para a tela de formulário de van
                  Navigator.pushNamed(context, '/add-van');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1), // Azul escuro
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}