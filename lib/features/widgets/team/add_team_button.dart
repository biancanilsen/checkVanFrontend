import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../provider/team_provider.dart';
import '../../pages/team/add_team_page.dart';

class AddTeamButton extends StatelessWidget {
  final TeamProvider teamProvider;

  const AddTeamButton({super.key, required this.teamProvider});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Nova turma',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    );
  }
}