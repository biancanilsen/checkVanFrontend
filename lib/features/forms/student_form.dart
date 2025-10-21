import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../core/theme.dart';
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
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();

  DateTime? _birthDate;
  String? _selectedGender;
  int? _selectedSchoolId;
  String? _selectedCity, _selectedState, _selectedCountry;
  double? _selectedLat, _selectedLon;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _addStudent() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _formKey.currentState?.reset();
    _nameController.clear();
    _birthDateController.clear();
    _streetController.clear();
    _numberController.clear();
    setState(() {
      _birthDate = null;
      _selectedGender = null;
      _selectedSchoolId = null;
      _selectedLat = null;
      _selectedLon = null;
      _selectedCity = null;
      _selectedState = null;
      _selectedCountry = null;
    });
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

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();
    final studentProvider = context.watch<StudentProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Adicionar aluno', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome completo'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'O nome é obrigatório' : null,
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(labelText: 'Logradouro'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'O logradouro é obrigatório' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(labelText: 'Nº'),
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            value: _selectedSchoolId,
            hint: Text(schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola'),
            decoration: const InputDecoration(labelText: 'Escola'),
            onChanged: schoolProvider.isLoading ? null : (v) => setState(() => _selectedSchoolId = v),
            validator: (value) => value == null ? 'A escola é obrigatória' : null,
            items: schoolProvider.schools.map((school) => DropdownMenuItem<int>(
              value: school.id,
              child: Text(school.name, overflow: TextOverflow.ellipsis),
            )).toList(),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Data nascimento'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _birthDateController.text.isEmpty ? 'dd/mm/aaaa' : _birthDateController.text,
                          style: TextStyle(fontSize: 16, color: _birthDateController.text.isEmpty ? Theme.of(context).hintColor : null),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  hint: const Text('Gênero'),
                  onChanged: (v) => setState(() => _selectedGender = v),
                  validator: (v) => v == null ? 'Obrigatório' : null,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Masculino')),
                    DropdownMenuItem(value: 'female', child: Text('Feminino')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.secondary500,
              foregroundColor: AppPalette.primary800,
            ),
            onPressed: studentProvider.isLoading ? null : _addStudent,
            child: studentProvider.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppPalette.primary800))
                : const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}