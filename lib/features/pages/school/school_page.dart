// Salve como: /lib/features/pages/school/escolas_page.dart
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

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
              // Header "Minhas escolas" (sem a seta de voltar)
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Text(
                  'Minhas escolas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Barra de Busca
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar escola',
                    suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    filled: true,
                    // Use a cor de card que criamos
                    fillColor: AppPalette.neutral70,
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
                clipBehavior: Clip.antiAlias, // Para os cantos arredondados
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    // Constrói a lista de escolas com divisores
                    _buildSchoolTile(mockEscolas[0]),
                    Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
                    _buildSchoolTile(mockEscolas[1]),
                    Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
                    _buildSchoolTile(mockEscolas[2]),
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

  // Helper para construir o item da lista (sem o divisor)
  Widget _buildSchoolTile(Map<String, String> escola) {
    return ListTile(
      leading: Icon(Icons.menu_book_outlined, color: Colors.grey[700]),
      title: Text(
        escola['name']!,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppPalette.primary900),
      ),
      subtitle: Text(
        escola['address']!,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[700]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
      onTap: () { /* Ação "Ver detalhes da escola" */ },
    );
  }
}