import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/trip_model.dart';
import '../../provider/trip_provider.dart';

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
    // 1. O Card agora define a forma e a elevação
    return Card(
      // Arredonda as bordas do Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      // Garante que o conteúdo (ExpansionTile) seja cortado para respeitar as bordas arredondadas
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2, // Adiciona uma pequena sombra
      child: Theme(
        // 2. Este Theme remove as linhas divisórias de cima e de baixo do ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // 3. Define as cores de fundo para os dois estados (recolhido e expandido)
          collapsedBackgroundColor: Colors.grey.shade50,
          backgroundColor: Colors.grey.shade100,

          title: Text('${widget.trip.startingPoint} -> ${widget.trip.endingPoint}', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Saída: ${widget.trip.departureTime}'),
          onExpansionChanged: (isExpanding) {
            if (isExpanding && !_hasFetched) {
              setState(() {
                _hasFetched = true;
              });
              Provider.of<TripProvider>(context, listen: false)
                  .getTeamsForTrip(widget.trip.id);
            }
          },
          children: <Widget>[
            // O conteúdo expandido agora tem um fundo da mesma cor
            _buildTeamDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamDetails() {
    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTeams(widget.trip.id)) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final teams = widget.trip.teams;

        if (teams == null) return const SizedBox.shrink();
        if (teams.isEmpty) return const ListTile(title: Text('Nenhuma turma encontrada para esta viagem.'));

        // Constrói a lista de turmas, e dentro de cada uma, a lista de alunos
        return Container(
          color: Colors.grey.shade100,
          child: Column(
            children: teams.map((team) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da Turma
                    Text(
                      team.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    // Lista de Alunos da Turma
                    if (team.students == null || team.students!.isEmpty)
                      const Text('Nenhum aluno nesta turma.', style: TextStyle(fontStyle: FontStyle.italic))
                    else
                      ...team.students!.map((student) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.person, size: 20),
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