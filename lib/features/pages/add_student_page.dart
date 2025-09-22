import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../provider/school_provider.dart';
import '../../provider/student_provider.dart';
import '../widgets/custom_text_field.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();

  // Variáveis de estado para os dados do formulário
  DateTime? _birthDate;
  String? _selectedGender;
  int? _selectedSchoolId;
  String? _selectedShiftGoing;
  String? _selectedShiftReturn;

  @override
  void initState() {
    super.initState();
    // Garante que a lista de escolas seja carregada ao iniciar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2010),
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

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final studentProvider = context.read<StudentProvider>();
    final success = await studentProvider.addStudent(
      name: _nameController.text,
      birthDate: _birthDate!,
      gender: _selectedGender!,
      schoolId: _selectedSchoolId!,
      address: _addressController.text,
      shiftGoing: _selectedShiftGoing!,
      shiftReturn: _selectedShiftReturn!,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno cadastrado com sucesso!'),
            backgroundColor: AppPalette.green500,
          ),
        );
        // Limpa o formulário
        _formKey.currentState?.reset();
        _nameController.clear();
        _birthDateController.clear();
        _addressController.clear();
        setState(() {
          _birthDate = null;
          _selectedGender = null;
          _selectedSchoolId = null;
          _selectedShiftGoing = null;
          _selectedShiftReturn = null;
        });
        Navigator.pushNamed(context, '/students');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(studentProvider.error ?? 'Ocorreu um erro.'),
            backgroundColor: AppPalette.red500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();
    final studentProvider = context.watch<StudentProvider>();
    const List<String> shiftOptions = ['Manhã', 'Tarde', 'Noite'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Aluno'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text('Dados do aluno', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary900)),
              const SizedBox(height: 8),
              const Text('Preencha os dados do aluno para realizar o cadastro', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppPalette.neutral600)),
              const SizedBox(height: 32),
              const Center(child: CircleAvatar(radius: 60, backgroundColor: AppPalette.neutral200, child: Icon(Icons.person, size: 80, color: AppPalette.neutral400))),
              const SizedBox(height: 32),

              // Formulário
              CustomTextField(controller: _nameController, label: 'Nome', hint: 'Nome do aluno', isRequired: true, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _birthDateController, label: 'Data de nascimento', hint: 'dd/mm/aaaa', isRequired: true, onTap: _pickDate, suffixIcon: Icons.calendar_today, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Gênero',
                hint: 'Selecione',
                value: _selectedGender,
                items: ['Masculino', 'Feminino'].map((gender) => DropdownMenuItem(value: gender.toLowerCase() == 'masculino' ? 'male' : 'female', child: Text(gender))).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(controller: _addressController, label: 'Endereço', hint: 'Rua, bairro, número', isRequired: true, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Escola',
                hint: schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola',
                value: _selectedSchoolId,
                items: schoolProvider.schools.map((school) => DropdownMenuItem(value: school.id, child: Text(school.name))).toList(),
                onChanged: schoolProvider.isLoading ? null : (value) => setState(() => _selectedSchoolId = value as int?),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Turno Ida',
                hint: 'Período da aula',
                value: _selectedShiftGoing,
                items: shiftOptions.map((shift) => DropdownMenuItem(value: shift, child: Text(shift))).toList(),
                onChanged: (value) => setState(() => _selectedShiftGoing = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Turno Volta',
                hint: 'Período da aula',
                value: _selectedShiftReturn,
                items: shiftOptions.map((shift) => DropdownMenuItem(value: shift, child: Text(shift))).toList(),
                onChanged: (value) => setState(() => _selectedShiftReturn = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: studentProvider.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                child: studentProvider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Cadastrar Aluno'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            children: [
              TextSpan(text: label),
              const TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(hint, style: Theme.of(context).inputDecorationTheme.hintStyle,),
          decoration: const InputDecoration(),
          borderRadius: BorderRadius.circular(12.0),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

