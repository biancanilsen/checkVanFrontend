import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/trip_model.dart';
import '../../provider/trip_provider.dart';
import '../forms/edit_trip_form.dart';

class TripExpansionTile extends StatefulWidget {
  final Trip trip;
  const TripExpansionTile({required this.trip, super.key});

  @override
  State<TripExpansionTile> createState() => _TripExpansionTileState();
}

class _TripExpansionTileState extends State<TripExpansionTile> {
  bool _hasFetched = false;

  @override
  Widget build(BuildContext context) {
    // Usamos um Provider.of aqui para ter acesso ao provider nos botões
    final provider = Provider.of<TripProvider>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.grey.shade200,
          backgroundColor: Colors.grey.shade100,
          title: Column(
            // Alinha o conteúdo de ambas as linhas à esquerda
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha para o Ponto de Partida
              Row(
                children: [
                  const Icon(Icons.trip_origin, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded( // Usamos Expanded para que o texto ocupe o espaço restante
                    child: Text(
                      widget.trip.startingPoint,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6), // Espaçamento vertical entre as duas linhas

              // Linha para o Ponto de Chegada
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.trip.endingPoint,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Text('Saída: ${widget.trip.departureTime}'),

          // --- MUDANÇA PRINCIPAL AQUI ---
          // Adicionamos os botões na área sempre visível do Tile
          trailing: Row(
            mainAxisSize: MainAxisSize.min, // Para a Row ocupar o mínimo de espaço
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                tooltip: 'Editar Viagem',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) => ChangeNotifierProvider.value(
                      value: provider,
                      child: EditTripForm(trip: widget.trip),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Deletar Viagem',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Confirmar Exclusão'),
                      content: Text('Deseja realmente deletar a viagem de ${widget.trip.startingPoint} para ${widget.trip.endingPoint}?'),
                      actions: [
                        TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Deletar'),
                          onPressed: () {
                            provider.deleteTrip(widget.trip.id);
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

          onExpansionChanged: (isExpanding) {
            if (isExpanding && !_hasFetched) {
              setState(() { _hasFetched = true; });
              provider.getTeamsForTrip(widget.trip.id);
            }
          },
          // O conteúdo expansível agora é apenas para os detalhes das turmas/alunos
          children: <Widget>[
            _buildTeamDetails(),
          ],
        ),
      ),
    );
  }

  // Este método agora foca apenas em exibir as turmas e alunos
  Widget _buildTeamDetails() {
    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        final tripFromProvider = provider.trips.firstWhere((t) => t.id == widget.trip.id, orElse: () => widget.trip);
        final teams = tripFromProvider.teams;

        if (provider.isLoadingTeams(widget.trip.id)) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (teams == null) return const SizedBox.shrink();

        if (teams.isEmpty) {
          return Container(
            color: Colors.grey.shade100,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: const Text('Nenhuma turma encontrada para esta viagem.'),
          );
        }

        return Container(
          color: Colors.grey.shade100,
          child: Column(
            children: teams.map((team) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    if (team.students == null || team.students!.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Text('Nenhum aluno nesta turma.', style: TextStyle(fontStyle: FontStyle.italic)),
                      )
                    else
                      ...team.students!.map((student) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.person, size: 20, color: Colors.blueGrey),
                        title: Text(student.name),
                      )),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}