import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/student_model.dart';
import '../../provider/student_provider.dart';
import 'package:intl/intl.dart';

class StudentForm extends StatefulWidget {
  const StudentForm({super.key});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController(); // visível formatado
  DateTime? _birthDate; // real data para lógica

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2010),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;

        // Mostra formatado no campo
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _addStudent() {
    if (_nameController.text.isEmpty || _birthDate == null) return;

    Provider.of<StudentProvider>(context, listen: false)
        .addStudent(_nameController.text, _birthDate!);

    _nameController.clear();
    _birthDateController.clear();
    _birthDate = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Adicionar aluno', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _birthDateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(labelText: 'Data nascimento'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addStudent,
            child: const Text('Adicionar'),
          ),
        ),
      ],
    );
  }
}
