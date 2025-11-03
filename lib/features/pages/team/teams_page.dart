import 'dart:async';
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/team_provider.dart';
import '../../widgets/team/team_card.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';
import 'add_team_page.dart';
import 'team_detail_page.dart'; // Import da nova tela

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).getTeams();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.read<TeamProvider>();

    return SafeArea(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            children: [
              const PageHeader(title: 'Minhas turmas'),

              PageSearchBar(
                hintText: 'Pesquisar turma ou aluno',
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    context.read<TeamProvider>().searchTeams(value);
                  });
                },
              ),

              Consumer<TeamProvider>(
                builder: (context, provider, child) {
                  return _buildTeamList(context, provider);
                },
              ),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nova turma', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: teamProvider,
                        child: const AddTeamPage(team: null),
                      ),
                    ),
                  );
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

  /// Constrói o widget correto baseado no estado do Provider
  Widget _buildTeamList(BuildContext context, TeamProvider provider) {
    if (provider.isLoading && provider.teams.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Erro: ${provider.error}"),
        ),
      );
    }

    if (provider.teams.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: Text("Nenhuma turma encontrada."),
        ),
      );
    }

    // --- INÍCIO DA CORREÇÃO ---
    // Removemos o Card() e o ListView.separated()
    // Retornamos uma Column, pois ela já está dentro de um ListView
    return Column(
      children: provider.teams.map((team) {
        // O TeamCard já é um Card e já tem a margem (bottom: 16.0)
        // Isso vai criar o espaçamento desejado.
        return TeamCard(
          name: team.name,
          period: team.shift,
          studentCount: team.students.length,
          code: team.code ?? 'N/A',
          onView: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // Navega para a TeamDetailPage
                builder: (_) => TeamDetailPage(team: team),
              ),
            );
          },
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: provider,
                  child: AddTeamPage(team: team),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}