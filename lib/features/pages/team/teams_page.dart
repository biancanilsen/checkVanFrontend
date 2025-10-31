import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import '../../widgets/team/team_card.dart';

final mockTurmas = [
  { 'name': 'Turma da manhã', 'period': 'manhã', 'students': 12, 'code': 'CHSGT5'},
  { 'name': 'Turma da tarde', 'period': 'tarde', 'students': 14, 'code': 'AJSK29'},
  { 'name': 'Turma da noite', 'period': 'noite', 'students': 10, 'code': 'PLQW77'},
];

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SEM SCAFFOLD, como conversamos
    return SafeArea(
      child: Stack( // Usamos Stack para o botão "+ Nova turma" ficar fixo
        children: [
          // 1. Conteúdo que rola (Header, Busca, Lista)
          ListView.builder(
            // Padding para o conteúdo não ser coberto pelo botão
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            itemCount: mockTurmas.length + 2, // +2 para o Header e a Busca
            itemBuilder: (context, index) {
              // Item 0: Header "Minhas turmas"
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                  child: Text(
                    'Minhas turmas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                     fontWeight: FontWeight.w500,
                      color: AppPalette.primary900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              // Item 1: Barra de Busca
              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar turma ou aluno',
                      suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true,
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
                );
              }

              // Itens da Lista
              final turma = mockTurmas[index - 2];
              return TeamCard(
                name: turma['name'].toString(),
                period: turma['period'].toString(),
                studentCount: turma['students'] as int,
                code: turma['code'].toString(),
              );
            },
          ),

          // 2. Botão Fixo "+ Nova turma"
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nova turma', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                onPressed: () {
                  // Navega para a tela de formulário
                  Navigator.pushNamed(context, '/add-team');
                },
                style: ElevatedButton.styleFrom(
                  // Cor azul escura do design
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