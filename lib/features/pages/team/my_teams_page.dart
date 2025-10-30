import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/features/widgets/team/period_selector.dart'; // Para o enum Period
import 'package:flutter/material.dart';

import '../../../model/team_model.dart';
import '../../widgets/team/search_bar.dart';
import '../../widgets/team/team_list_tile.dart';
import 'add_team_page.dart';
// TODO: Importar o provider de turmas (TeamProvider) quando for usar dados reais

class MyTeamsPage extends StatefulWidget {
  const MyTeamsPage({super.key});

  @override
  State<MyTeamsPage> createState() => _MyTeamsPageState();
}

class _MyTeamsPageState extends State<MyTeamsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Team> _allTeams = [];
  List<Team> _filteredTeams = [];
  bool _isLoading = false; // Estado de carregamento

  @override
  void initState() {
    super.initState();
    // TODO: Chamar o provider para carregar as turmas reais aqui
    _loadMockTeams(); // Carrega os dados simulados
    _searchController.addListener(_filterTeams);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTeams);
    _searchController.dispose();
    super.dispose();
  }

  // Simula o carregamento (substituir por chamada ao provider)
  void _loadMockTeams() {
    setState(() {
      _isLoading = true; // Inicia o carregamento
    });
    // Simula delay da rede
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _allTeams = [
        Team(id: 1, name: 'Turma da manhã', students: [], schoolId: 1, studentCount: 12),
        Team(id: 2, name: 'Turma da tarde A', students: [], schoolId: 1, studentCount: 12),
        Team(id: 3, name: 'Turma da noite B', students: [], schoolId: 1, studentCount: 12),
      ];
      _filteredTeams = _allTeams;
      setState(() {
        _isLoading = false; // Termina o carregamento
      });
    });
  }

  void _filterTeams() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTeams = _allTeams.where((team) {
        return team.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToCreateTeam() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTeamPage()),
    ).then((_) {
      // TODO: Recarregar as turmas após adicionar uma nova, se necessário
      // _loadMockTeams(); // Ou chamar o método do provider
    });
  }

  void _handleEditTeam(Team team) {
    print('Editar turma: ${team.name}');
    // TODO: Implementar navegação para tela de edição de turma
  }

  void _handleViewTeam(Team team) {
    print('Ver detalhes da turma: ${team.name}');
    // TODO: Implementar navegação para tela de detalhes da turma
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Minhas turmas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Assumindo que esta tela foi empilhada
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0), // Ajuste no padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Pesquisar turma ou aluno',
                  onSearchPressed: _filterTeams,
                ),
                const SizedBox(height: 16),

                _isLoading
                    ? const Expanded( // Usa Expanded para centralizar o loader
                  child: Center(child: CircularProgressIndicator()),
                )
                    : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90), // Espaço para o botão
                    itemCount: _filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = _filteredTeams[index];
                      return TeamListTile(
                        team: team,
                        onEdit: () => _handleEditTeam(team),
                        onViewTeam: () => _handleViewTeam(team),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Botão "Nova turma" posicionado
          Positioned(
            bottom: 24, // Distância da borda inferior
            left: 24,   // Distância da borda esquerda
            right: 24,  // Distância da borda direita
            child: ElevatedButton.icon(
              onPressed: _navigateToCreateTeam,
              icon: const Icon(Icons.add, size: 24),
              label: const Text('Nova turma'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary800,
                foregroundColor: AppPalette.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
