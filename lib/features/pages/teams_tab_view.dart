import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/team_model.dart';
import '../../provider/student_provider.dart';
import '../../provider/team_provider.dart';
import '../../provider/trip_provider.dart';
import '../forms/edit_team_form.dart';
import '../forms/team_form.dart';
import '../widgets/manage_team_students_modal.dart';

class TeamsTabView extends StatefulWidget {
  const TeamsTabView({super.key});

  @override
  State<TeamsTabView> createState() => _TeamsTabViewState();
}

class _TeamsTabViewState extends State<TeamsTabView> {
  @override
  void initState() {
    super.initState();
    // Garante que a lista de turmas seja carregada ao iniciar a aba
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).getTeams();
    });
  }

  /// Abre o Bottom Sheet para cadastrar uma nova turma
  void _openAddTeamSheet() {
    // Pega as instâncias dos providers que o formulário precisará
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (modalContext) {
        return Container(
          // Define uma altura padrão para o sheet (50% da tela)
          height: MediaQuery.of(context).size.height * 0.5,
          // Fornece os providers para o formulário
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: teamProvider),
              ChangeNotifierProvider.value(value: tripProvider),
            ],
            child: const TeamForm(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.teams.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Erro: ${provider.error!}'));
          }
          if (provider.teams.isEmpty) {
            return const Center(child: Text('Nenhuma turma cadastrada.'));
          }

          // A lista de turmas
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.teams.length,
            itemBuilder: (context, index) {
              final team = provider.teams[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.0),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: Provider.of<TeamProvider>(context, listen: false)),
                          ChangeNotifierProvider.value(value: Provider.of<StudentProvider>(context, listen: false)),
                        ],
                        child: ManageTeamStudentsModal(team: team),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                team.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  tooltip: 'Editar Turma',
                                  onPressed: () {
                                    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
                                    final tripProvider = Provider.of<TripProvider>(context, listen: false);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) => MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider.value(value: teamProvider),
                                          ChangeNotifierProvider.value(value: tripProvider),
                                        ],
                                        child: EditTeamForm(team: team),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: 'Deletar Turma',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Confirmar Exclusão'),
                                        content: Text('Você tem certeza que deseja deletar a turma "${team.name}"?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancelar'),
                                            onPressed: () => Navigator.of(dialogContext).pop(),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                            child: const Text('Deletar'),
                                            onPressed: () {
                                              Provider.of<TeamProvider>(context, listen: false).deleteTeam(team.id);
                                              Navigator.of(dialogContext).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text('Viagem: ${team.trip?.startingPoint ?? "N/A"} -> ${team.trip?.schoolName ?? "N/A"}'),
                        const SizedBox(height: 4),
                        Text('Alunos na turma: ${team.students.length}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTeamSheet,
        tooltip: 'Adicionar Nova Turma',
        child: const Icon(Icons.add),
      ),
    );
  }
}