import 'dart:async';
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/team_provider.dart';
import '../../widgets/team/add_team_button.dart';
import '../../widgets/team/team_list_content.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';

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
                  return TeamListContent(provider: provider);
                },
              ),
            ],
          ),

          AddTeamButton(teamProvider: teamProvider),
        ],
      ),
    );
  }
}