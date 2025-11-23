import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/team_provider.dart';
import '../../pages/team/add_team_page.dart';
import '../../pages/team/team_detail_page.dart';
import '../../widgets/team/team_card.dart';

class TeamListContent extends StatelessWidget {
  final TeamProvider provider;

  const TeamListContent({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
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

    return Column(
      children: provider.teams.map((team) {
        return TeamCard(
          name: team.name,
          period: team.shift,
          studentCount: team.students.length,
          code: team.code ?? 'N/A',
          onView: () {
            Navigator.push(
              context,
              MaterialPageRoute(
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