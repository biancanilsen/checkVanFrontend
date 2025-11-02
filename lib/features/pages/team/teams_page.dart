// /lib/features/pages/team/teams_page.dart
import 'dart:async';
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/team_provider.dart';
import '../../widgets/team/team_card.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';
import 'add_team_page.dart';

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
    // Pegamos o provider com 'read' para usar no botão de Adicionar
    final teamProvider = context.read<TeamProvider>();

    return SafeArea(
      child: Stack(
        children: [
          // 1. O CONTEÚDO QUE ROLA
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            children: [
              const PageHeader(title: 'Minhas turmas'),

              PageSearchBar(
                hintText: 'Pesquisar turma ou aluno',
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    // Usamos context.read aqui
                    context.read<TeamProvider>().searchTeams(value);
                  });
                },
              ),

              // 2. A LISTA DINÂMICA
              // O Consumer escuta as mudanças (loading, error, empty, data)
              Consumer<TeamProvider>(
                builder: (context, provider, child) {
                  // Chamamos o helper para construir o widget correto
                  return _buildTeamList(context, provider);
                },
              ),
            ],
          ),

          // 3. BOTÃO FIXO "+ Nova turma"
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
                        value: teamProvider, // Passa o provider da lista
                        child: const AddTeamPage(team: null), // null = Criar
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

    // --- ESTA É A CONDIÇÃO QUE VOCÊ PEDIU ---
    if (provider.teams.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: Text("Nenhuma turma encontrada."),
        ),
      );
    }
    // --- FIM DA CONDIÇÃO ---

    // Se tiver dados, constrói a lista
    return Card(
      color: AppPalette.neutral70,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.teams.length,
        itemBuilder: (context, index) {
          final team = provider.teams[index];
          return TeamCard(
            name: team.name,
            period: team.shift,
            studentCount: team.students.length,
            code: team.code ?? 'N/A',
            onView: () {
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
        },
        separatorBuilder: (context, index) =>
            Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
      ),
    );
  }
}