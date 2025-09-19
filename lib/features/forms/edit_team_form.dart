import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/team_model.dart';
import '../../../provider/team_provider.dart';
import '../../../provider/trip_provider.dart';

class EditTeamForm extends StatefulWidget {
  final Team team;
  const EditTeamForm({required this.team, super.key});

  @override
  State<EditTeamForm> createState() => _EditTeamFormState();
}

class _EditTeamFormState extends State<EditTeamForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  int? _selectedTripId;

  @override
  void initState() {
    super.initState();
    // Pré-preenche o formulário com os dados da turma
    _nameController = TextEditingController(text: widget.team.name);
    _selectedTripId = widget.team.trip?.id;

    // Garante que a lista de viagens esteja disponível para o dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).getTrips();
    });
  }

  void _submitUpdate() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<TeamProvider>(context, listen: false)
        .updateTeam(
      teamId: widget.team.id,
      name: _nameController.text,
      tripId: _selectedTripId!,
    )
        .then((success) {
      if (success && mounted) {
        Navigator.of(context).pop(); // Fecha o Bottom Sheet
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();
    final tripProvider = context.watch<TripProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Editar Turma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome da Turma'),
              validator: (value) => value!.isEmpty ? 'O nome é obrigatório' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedTripId,
              hint: Text(tripProvider.isLoading ? 'Carregando...' : 'Selecione a viagem'),
              decoration: const InputDecoration(labelText: 'Viagem Associada'),
              items: tripProvider.trips.map((trip) {
                return DropdownMenuItem<int>(
                  value: trip.id,
                  child: Text('${trip.startingPoint} -> ${trip.schoolName}'),
                );
              }).toList(),
              onChanged: tripProvider.isLoading ? null : (value) {
                setState(() => _selectedTripId = value);
              },
              validator: (value) => value == null ? 'A viagem é obrigatória' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: teamProvider.isLoading ? null : _submitUpdate,
                child: const Text('Atualizar Turma'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}