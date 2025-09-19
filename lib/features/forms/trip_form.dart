// lib/view/widgets/forms/trip_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/school_provider.dart'; // Importe o provider de escolas
import '../../../provider/trip_provider.dart';

class TripForm extends StatefulWidget {
  const TripForm({super.key});

  @override
  State<TripForm> createState() => _TripFormState();
}

class _TripFormState extends State<TripForm> {
  final _formKey = GlobalKey<FormState>();
  final _startPointController = TextEditingController();

  // Controller do ponto de chegada foi removido

  TimeOfDay? _departureTime;
  TimeOfDay? _arrivalTime;
  int? _selectedSchoolId; // Nova variável para o ID da escola

  @override
  void initState() {
    super.initState();
    // Garante que a lista de escolas seja carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });
  }

  Future<void> _pickTime(BuildContext context, {required bool isDeparture}) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isDeparture) _departureTime = pickedTime;
        else _arrivalTime = pickedTime;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_departureTime == null || _arrivalTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione os horários.')),
      );
      return;
    }

    Provider.of<TripProvider>(context, listen: false).addTrip(
      departureTime: _departureTime!,
      arrivalTime: _arrivalTime!,
      startingPoint: _startPointController.text,
      schoolId: _selectedSchoolId!, // Passa o ID da escola
    ).then((success) {
      if (success && mounted) {
        Navigator.of(context).pop(); // Fecha o Bottom Sheet
      }
    });
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Selecionar horário';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final schoolProvider = context.watch<SchoolProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cadastrar nova viagem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextFormField(
              controller: _startPointController,
              decoration: const InputDecoration(labelText: 'Ponto de Partida (Endereço)'),
              validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 12),

            // --- CAMPO DE PONTO DE CHEGADA SUBSTITUÍDO PELO DROPDOWN DE ESCOLAS ---
            DropdownButtonFormField<int>(
              value: _selectedSchoolId,
              hint: Text(schoolProvider.isLoading ? 'Carregando escolas...' : 'Selecione a escola de destino'),
              decoration: const InputDecoration(labelText: 'Escola (Ponto de Chegada)'),
              isExpanded: true,
              items: schoolProvider.schools.map((school) {
                return DropdownMenuItem<int>(
                  value: school.id,
                  child: Text(school.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: schoolProvider.isLoading ? null : (newValue) {
                setState(() {
                  _selectedSchoolId = newValue;
                });
              },
              validator: (value) => value == null ? 'A escola é obrigatória' : null,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: InkWell(onTap: () => _pickTime(context, isDeparture: true), child: InputDecorator(decoration: const InputDecoration(labelText: 'Horário de Saída'), child: Text(_formatTime(_departureTime))))),
                const SizedBox(width: 12),
                Expanded(child: InkWell(onTap: () => _pickTime(context, isDeparture: false), child: InputDecorator(decoration: const InputDecoration(labelText: 'Horário de Chegada'), child: Text(_formatTime(_arrivalTime))))),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: tripProvider.isLoading ? null : _submitForm,
                child: tripProvider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}