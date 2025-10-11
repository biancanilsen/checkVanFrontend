import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/team_provider.dart';
import '../../../provider/trip_provider.dart';

class TeamForm extends StatefulWidget {
  const TeamForm({super.key});

  @override
  State<TeamForm> createState() => _TeamFormState();
}

class _TeamFormState extends State<TeamForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int? _selectedTripId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).getTrips();
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<TeamProvider>(context, listen: false)
        .addTeam(name: _nameController.text, tripId: _selectedTripId!)
        .then((success) {
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();
    final tripProvider = context.watch<TripProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cadastrar nova turma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome da Turma'),
              validator: (value) => value!.isEmpty ? 'O nome é obrigatório' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedTripId,
              hint: Text(tripProvider.isLoading ? 'Carregando viagens...' : 'Selecione a viagem'),
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
                onPressed: teamProvider.isLoading ? null : _submitForm,
                child: const Text('Salvar Turma'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}