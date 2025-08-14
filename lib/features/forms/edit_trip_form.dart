import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/trip_model.dart';
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
  late TextEditingController _endPointController;
  late TimeOfDay _departureTime;
  late TimeOfDay _arrivalTime;

  @override
  void initState() {
    super.initState();
    // Pré-preenche o formulário com os dados existentes
    _startPointController = TextEditingController(text: widget.trip.startingPoint);
    _endPointController = TextEditingController(text: widget.trip.endingPoint);

    // Converte a string "HH:mm" de volta para TimeOfDay
    final depParts = widget.trip.departureTime.split(':');
    _departureTime = TimeOfDay(hour: int.parse(depParts[0]), minute: int.parse(depParts[1]));

    final arrParts = widget.trip.arrivalTime.split(':');
    _arrivalTime = TimeOfDay(hour: int.parse(arrParts[0]), minute: int.parse(arrParts[1]));
  }

  Future<void> _pickTime({required bool isDeparture}) async {
    final picked = await showTimePicker(context: context, initialTime: isDeparture ? _departureTime : _arrivalTime);
    if (picked != null) {
      setState(() {
        if (isDeparture) _departureTime = picked;
        else _arrivalTime = picked;
      });
    }
  }

  void _submitUpdate() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<TripProvider>(context, listen: false).updateTrip(
      id: widget.trip.id,
      departureTime: _departureTime,
      arrivalTime: _arrivalTime,
      startingPoint: _startPointController.text,
      endingPoint: _endPointController.text,
    );

    Navigator.of(context).pop(); // Fecha o Bottom Sheet
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
            // ... (Campos TextFormField e Row com horários, igual ao TripForm)
            TextFormField(controller: _startPointController, decoration: const InputDecoration(labelText: 'Ponto de Partida')),
            const SizedBox(height: 12),
            TextFormField(controller: _endPointController, decoration: const InputDecoration(labelText: 'Ponto de Chegada')),
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