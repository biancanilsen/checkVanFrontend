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

  // Controllers para todos os campos
  late TextEditingController _nameController;
  late TextEditingController _birthDateController;
  late TextEditingController _addressController;

  // Variáveis de estado
  late DateTime _birthDate;
  late String _selectedGender;
  int? _selectedSchoolId;

  @override
  void initState() {
    super.initState();
    // Pré-preenche o formulário com os dados do aluno
    _nameController = TextEditingController(text: widget.student.name);
    _addressController = TextEditingController(text: widget.student.address);
    _birthDate = widget.student.birthDate;
    _birthDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.student.birthDate),
    );
    _selectedGender = widget.student.gender;
    _selectedSchoolId = widget.student.schoolId;
  }

  void _pickDate() async {
    // ... (seu método _pickDate, sem alterações)
  }

  void _updateStudent() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<StudentProvider>(context, listen: false).updateStudent(
      widget.student.id,
      _nameController.text,
      _birthDate,
      _selectedGender,
      _selectedSchoolId!,
      _addressController.text,
    );

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose(); // Dispose do novo controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Assiste ao SchoolProvider para obter a lista de escolas
    final schoolProvider = context.watch<SchoolProvider>();

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    decoration: const InputDecoration(labelText: 'Data nascimento'),
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateStudent,
                child: const Text('Atualizar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}