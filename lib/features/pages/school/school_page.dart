// /lib/features/pages/school/escolas_page.dart
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
// 1. IMPORTE O NOVO WIDGET
import '../../widgets/school/school_tile.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';

// Dados mocados (substitua pelo seu endpoint futuramente)
final mockEscolas = [
  {
    'name': 'EBM Bilíngue Prof. Oscar Unbehaun',
    'address': 'R. Garopaba, 213 – Água Verde, Bl...'
  },
  {
    'name': 'Colégio Castelo Branco',
    'address': 'R. Eng. Udo Deeke, 531 - Salto Norte, Bl...'
  },
  {
    'name': 'EBM Almirante Tamandaré',
    'address': 'R. Mal. Deodoro, 1280 - Velha, Bl...'
  },
];

class SchoolPage extends StatelessWidget {
  const SchoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SEM SCAFFOLD, como conversamos
    return SafeArea(
      child: Stack( // Usamos Stack para o botão "+ Nova escola" ficar fixo
        children: [
          // 1. Conteúdo que rola (Header, Busca, Lista)
          ListView(
            // Padding para o conteúdo não ser coberto pelo botão
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            children: [
              const PageHeader(title: 'Minhas escolas'),

              PageSearchBar(
              hintText: 'Pesquisar escola',
              onChanged: (value) {
              // Você pode adicionar sua lógica de filtro aqui
              // provider.filterStudents(value);
              },
              ),

              // Card que agrupa os itens da lista
              Card(
                color: AppPalette.neutral70,
                clipBehavior: Clip.antiAlias, // Para os cantos arredondados
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    // 2. USE O NOVO WIDGET AQUI
                    SchoolTile(
                      name: mockEscolas[0]['name']!,
                      address: mockEscolas[0]['address']!,
                      onTap: () { /* Ação "Ver detalhes da escola" */ },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
                    SchoolTile(
                      name: mockEscolas[1]['name']!,
                      address: mockEscolas[1]['address']!,
                      onTap: () { /* Ação "Ver detalhes da escola" */ },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
                    SchoolTile(
                      name: mockEscolas[2]['name']!,
                      address: mockEscolas[2]['address']!,
                      onTap: () { /* Ação "Ver detalhes da escola" */ },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Botão Fixo "+ Nova escola"
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nova escola', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Navega para a tela de formulário de escola
                  Navigator.pushNamed(context, '/add-school');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800, // Azul escuro
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