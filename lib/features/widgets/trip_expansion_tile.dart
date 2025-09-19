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
  // 1. Variável para controlar o estado de expansão
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TripProvider>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              collapsedBackgroundColor: Colors.grey.shade50,
              backgroundColor: Colors.grey.shade100,

              // --- CÓDIGO DO TÍTULO QUE ESTAVA FALTANDO ---
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.trip.startingPoint,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.trip.schoolName ?? 'Destino não informado',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // --- CÓDIGO DO SUBTÍTULO ---
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Saída: ${widget.trip.departureTime}'),
              ),

              // --- CÓDIGO DOS BOTÕES QUE ESTAVA FALTANDO ---
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
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
                    tooltip: 'Excluir Viagem',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: Text('Deseja realmente excluir a viagem de ${widget.trip.startingPoint} para ${widget.trip.schoolName ?? "destino"}?'),
                          actions: [
                            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Excluir'),
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
                setState(() { _isExpanded = isExpanding; });
                if (isExpanding && !_hasFetched) {
                  setState(() { _hasFetched = true; });
                  provider.getTeamsForTrip(widget.trip.id);
                }
              },
              children: <Widget>[
                _buildTeamDetails(),
              ],
            ),
          ),

          // O ícone animado continua aqui
          Positioned(
            bottom: 6,
            child: IgnorePointer(
              child: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo que aparece ao expandir o card
  Widget _buildTeamDetails() {
    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        final tripFromProvider = provider.trips.firstWhere((t) => t.id == widget.trip.id, orElse: () => widget.trip);
        final teams = tripFromProvider.teams;

        if (provider.isLoadingTeams(widget.trip.id)) {
          return Container(
            height: 100, // <-- Define uma altura fixa para a área de loading. Ajuste se necessário.
            alignment: Alignment.center, // Centraliza o spinner dentro desta área de 100px.
            child: const CircularProgressIndicator(),
          );
        }

        if (teams == null) return const SizedBox.shrink();

        if (teams.isEmpty) {
          return Container(
            color: Colors.grey.shade100,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8.0),
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