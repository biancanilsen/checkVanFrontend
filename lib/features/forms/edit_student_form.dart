import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../model/student_model.dart';
import '../../../provider/student_provider.dart';

class EditStudentForm extends StatefulWidget {
  final Student student;

  const EditStudentForm({required this.student, super.key});

  @override
  State<EditStudentForm> createState() => _EditStudentFormState();
}

class _EditStudentFormState extends State<EditStudentForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _birthDateController;

  late DateTime _birthDate;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _birthDate = widget.student.birthDate;
    _birthDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.student.birthDate),
    );
    _selectedGender = widget.student.gender;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _updateStudent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Provider.of<StudentProvider>(context, listen: false).updateStudent(
      widget.student.id, // Passa o ID do aluno
      _nameController.text,
      _birthDate,
      _selectedGender,
    );

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome completo'),
            validator: (value) => value!.trim().isEmpty ? 'O nome é obrigatório' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _birthDateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(labelText: 'Data nascimento'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(labelText: 'Gênero'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Masculino')),
              DropdownMenuItem(value: 'female', child: Text('Feminino')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedGender = value);
              }
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateStudent,
            child: const Text('Atualizar'),
          )
        ],
      ),
    );
  }
}