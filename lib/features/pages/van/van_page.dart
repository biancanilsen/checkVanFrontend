import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';
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
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            children: [
              const PageHeader(title: 'Minhas vans'),

              PageSearchBar(
                hintText: 'Pesquisar modelo ou placa',
                onChanged: (value) {
                  // Você pode adicionar sua lógica de filtro aqui
                  // provider.filterStudents(value);
                },
              ),

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
                  backgroundColor: AppPalette.primary800,
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