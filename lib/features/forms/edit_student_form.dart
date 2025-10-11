import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../model/student_model.dart';
import '../../../provider/school_provider.dart';
import '../../../provider/student_provider.dart';

class EditStudentForm extends StatefulWidget {
  final Student student;
  const EditStudentForm({required this.student, super.key});

  @override
  State<EditStudentForm> createState() => _EditStudentFormState();
}

class _EditStudentFormState extends State<EditStudentForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _birthDateController;
  late TextEditingController _addressController;

  // Variáveis de estado
  late DateTime _birthDate;
  late String _selectedGender;
  int? _selectedSchoolId;
  late String _selectedShiftGoing;
  late String _selectedShiftReturn;

  // --- AJUSTE: Mapeamento dos valores internos para os textos de exibição ---
  final Map<String, String> shiftOptions = {
    'morning': 'Manhã',
    'afternoon': 'Tarde',
    'night': 'Noite',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _addressController = TextEditingController(text: widget.student.address);
    _birthDate = widget.student.birthDate;
    _birthDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.student.birthDate),
    );
    _selectedGender = widget.student.gender;
    _selectedSchoolId = widget.student.schoolId;
    _selectedShiftGoing = widget.student.shiftGoing;
    _selectedShiftReturn = widget.student.shiftReturn;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    final success = await studentProvider.updateStudent(
      id: widget.student.id,
      name: _nameController.text,
      birthDate: _birthDate,
      gender: _selectedGender,
      schoolId: _selectedSchoolId!,
      address: _addressController.text,
      shiftGoing: _selectedShiftGoing,
      shiftReturn: _selectedShiftReturn,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(studentProvider.error ?? 'Falha ao atualizar'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome completo'),
              validator: (v) => v!.trim().isEmpty ? 'O nome é obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Endereço completo'),
              validator: (v) => v!.trim().isEmpty ? 'O endereço é obrigatório' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedSchoolId,
              hint: Text(schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola'),
              decoration: const InputDecoration(labelText: 'Escola'),
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
                Expanded(
                  child: TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: const InputDecoration(labelText: 'Data nascimento', suffixIcon: Icon(Icons.calendar_today)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gênero'),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Masculino')),
                      DropdownMenuItem(value: 'female', child: Text('Feminino')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedGender = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedShiftGoing,
                    decoration: const InputDecoration(labelText: 'Turno Ida'),
                    // --- AJUSTE: Usando o Map para criar os itens ---
                    items: shiftOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,   // O valor interno, ex: "morning"
                        child: Text(entry.value), // O texto de exibição, ex: "Manhã"
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedShiftGoing = value);
                    },
                    validator: (v) => v == null ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedShiftReturn,
                    decoration: const InputDecoration(labelText: 'Turno Volta'),
                    // --- AJUSTE: Usando o Map para criar os itens ---
                    items: shiftOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedShiftReturn = value);
                    },
                    validator: (v) => v == null ? 'Obrigatório' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateStudent,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Atualizar Aluno'),
            ),
          ],
        ),
      ),
    );
  }
}