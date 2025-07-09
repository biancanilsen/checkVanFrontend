import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/student_provider.dart';

class StudentForm extends StatefulWidget {
  const StudentForm({super.key});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();

  DateTime? _birthDate;
  String? _selectedGender;

  void _pickDate() async {
    FocusScope.of(context).requestFocus(FocusNode());

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2010),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _addStudent() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Provider.of<StudentProvider>(context, listen: false).addStudent(
      _nameController.text,
      _birthDate!,
      _selectedGender!,
    );

    _formKey.currentState?.reset();
    _nameController.clear();
    _birthDateController.clear();
    setState(() {
      _birthDate = null;
      _selectedGender = null;
    });
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adicionar aluno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome completo'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'O nome é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(labelText: 'Data nascimento'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione a data';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  hint: const Text('Gênero'),
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione o gênero' : null,
                  items: const [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text('Masculino'),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text('Feminino'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addStudent,
              child: const Text('Adicionar'),
            ),
          ),
        ],
      ),
    );
  }
}