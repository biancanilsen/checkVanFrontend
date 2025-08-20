import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../provider/school_provider.dart';
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
  final _addressController = TextEditingController(); // Controller para o endereço

  DateTime? _birthDate;
  String? _selectedGender;
  int? _selectedSchoolId;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose(); // Não se esqueça do dispose
    super.dispose();
  }

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
      _selectedSchoolId!,
      _addressController.text, // Passa o valor do campo de endereço
    );

    // Limpa todos os campos do formulário
    _formKey.currentState?.reset();
    _nameController.clear();
    _birthDateController.clear();
    _addressController.clear();
    setState(() {
      _birthDate = null;
      _selectedGender = null;
      _selectedSchoolId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();
    final studentProvider = context.watch<StudentProvider>();

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
            validator: (value) => (value == null || value.trim().isEmpty) ? 'O nome é obrigatório' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Endereço completo'),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'O endereço é obrigatório' : null,
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<int>(
            value: _selectedSchoolId,
            // 1. O hint (texto de dica) muda para indicar o carregamento
            hint: Text(schoolProvider.isLoading ? 'Carregando escolas...' : 'Selecione a escola'),
            decoration: const InputDecoration(labelText: 'Escola'),
            isExpanded: true,
            items: schoolProvider.schools.map((school) {
              return DropdownMenuItem<int>(
                value: school.id,
                child: Text(school.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            // 2. A propriedade onChanged se torna nula durante o carregamento, desabilitando o campo
            onChanged: schoolProvider.isLoading ? null : (newValue) {
              setState(() {
                _selectedSchoolId = newValue;
              });
            },
            validator: (value) => value == null ? 'Escola é obrigatória' : null,
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
                  validator: (value) => (value == null || value.isEmpty) ? 'Selecione a data' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  hint: const Text('Gênero'),
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  onChanged: (String? newValue) => setState(() => _selectedGender = newValue),
                  validator: (value) => value == null ? 'Selecione o gênero' : null,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Masculino')),
                    DropdownMenuItem(value: 'female', child: Text('Feminino')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: studentProvider.isLoading ? null : _addStudent,
              child: studentProvider.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Adicionar'),
            ),
          ),
        ],
      ),
    );
  }
}