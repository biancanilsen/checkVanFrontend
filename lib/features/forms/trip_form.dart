import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/trip_provider.dart';

class TripForm extends StatefulWidget {
  const TripForm({super.key});

  @override
  State<TripForm> createState() => _TripFormState();
}

class _TripFormState extends State<TripForm> {
  final _formKey = GlobalKey<FormState>();
  final _startPointController = TextEditingController();
  final _endPointController = TextEditingController();

  TimeOfDay? _departureTime;
  TimeOfDay? _arrivalTime;

  Future<void> _pickTime(BuildContext context, {required bool isDeparture}) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = pickedTime;
        } else {
          _arrivalTime = pickedTime;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
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
        endingPoint: _endPointController.text,
      ).then((success) {
        if (success) {
          // Limpa o formulário
          _formKey.currentState!.reset();
          _startPointController.clear();
          _endPointController.clear();
          setState(() {
            _departureTime = null;
            _arrivalTime = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Viagem adicionada com sucesso!')),
          );
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Selecionar horário';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cadastrar Nova Viagem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _startPointController,
            decoration: const InputDecoration(labelText: 'Ponto de Partida'),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _endPointController,
            decoration: const InputDecoration(labelText: 'Ponto de Chegada'),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickTime(context, isDeparture: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Horário de Saída'),
                    child: Text(_formatTime(_departureTime)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _pickTime(context, isDeparture: false),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Horário de Chegada'),
                    child: Text(_formatTime(_arrivalTime)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Se estiver carregando, onPressed é null (desabilitado), senão, usa _submitForm
              onPressed: tripProvider.isLoading ? null : _submitForm,
              child: tripProvider.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Adicionar'),
            ),
          ),
        ],
      ),
    );
  }
}