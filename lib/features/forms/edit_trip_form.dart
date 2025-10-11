import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/trip_model.dart';
import '../../../provider/school_provider.dart';
import '../../../provider/trip_provider.dart';

class EditTripForm extends StatefulWidget {
  final Trip trip;
  const EditTripForm({required this.trip, super.key});

  @override
  State<EditTripForm> createState() => _EditTripFormState();
}

class _EditTripFormState extends State<EditTripForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _startPointController;
  late TimeOfDay _departureTime;
  late TimeOfDay _arrivalTime;
  int? _selectedSchoolId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });

    _startPointController = TextEditingController(text: widget.trip.startingPoint);
    _selectedSchoolId = widget.trip.schoolId;

    final depParts = widget.trip.departureTime.split(':');
    _departureTime = TimeOfDay(hour: int.parse(depParts[0]), minute: int.parse(depParts[1]));

    final arrParts = widget.trip.arrivalTime.split(':');
    _arrivalTime = TimeOfDay(hour: int.parse(arrParts[0]), minute: int.parse(arrParts[1]));
  }

  Future<void> _pickTime({required bool isDeparture}) async {
  }

  void _submitUpdate() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<TripProvider>(context, listen: false).updateTrip(
      id: widget.trip.id,
      departureTime: _departureTime,
      arrivalTime: _arrivalTime,
      startingPoint: _startPointController.text,
      schoolId: _selectedSchoolId!, // Passa o ID da escola
    );

    Navigator.of(context).pop();
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Editar Viagem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(controller: _startPointController, decoration: const InputDecoration(labelText: 'Ponto de Partida')),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: _selectedSchoolId,
              hint: Text(schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola'),
              decoration: const InputDecoration(labelText: 'Escola (Ponto de Chegada)'),
              items: schoolProvider.schools.map((school) {
                return DropdownMenuItem<int>(value: school.id, child: Text(school.name));
              }).toList(),
              onChanged: schoolProvider.isLoading ? null : (value) {
                setState(() => _selectedSchoolId = value);
              },
              validator: (value) => value == null ? 'A escola é obrigatória' : null,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: InkWell(onTap: () => _pickTime(isDeparture: true), child: InputDecorator(decoration: const InputDecoration(labelText: 'Horário de Saída'), child: Text(_formatTime(_departureTime))))),
                const SizedBox(width: 12),
                Expanded(child: InkWell(onTap: () => _pickTime(isDeparture: false), child: InputDecorator(decoration: const InputDecoration(labelText: 'Horário de Chegada'), child: Text(_formatTime(_arrivalTime))))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _submitUpdate, child: const Text('Atualizar')),
            )
          ],
        ),
      ),
    );
  }
}