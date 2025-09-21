import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../widgets/custom_text_field.dart'; // 1. Importe o novo widget

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _schoolController = TextEditingController();
  final _shiftController = TextEditingController();
  final _vanController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _schoolController.dispose();
    _shiftController.dispose();
    _vanController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (pickedDate != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  // 2. O método _buildTextField foi REMOVIDO daqui.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Dados do aluno', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppPalette.primary900)),
            const SizedBox(height: 8),
            const Text('Preencha os dados do aluno para realizar o cadastro', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppPalette.neutral900, fontWeight: FontWeight.w500)),
            const SizedBox(height: 18),
            const Center(child: CircleAvatar(radius: 60, backgroundColor: AppPalette.neutral200, child: Icon(Icons.person, size: 100, color: AppPalette.neutral400))),
            const SizedBox(height: 8),

            CustomTextField(
              controller: _nameController,
              label: 'Nome',
              hint: 'Nome do aluno',
              isRequired: true,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'O nome é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _birthDateController,
              label: 'Data de nascimento',
              hint: 'dd/mm/aaaa',
              suffixIcon: Icons.calendar_today,
              onTap: _pickDate,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppPalette.neutral900, fontFamily: 'Poppins'),
                    children: [
                      TextSpan(text: 'Gênero'),
                      TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  hint: Text(
                    'Selecione',
                    style: Theme.of(context).inputDecorationTheme.hintStyle,
                  ),
                  decoration: const InputDecoration(),
                  borderRadius: BorderRadius.circular(24.0),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Masculino')),
                    DropdownMenuItem(value: 'female', child: Text('Feminino')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null ? 'O gênero é obrigatório' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextField(controller: _addressController, label: 'Endereço', hint: 'Rua, bairro, número', isRequired: true),
            const SizedBox(height: 16),
            CustomTextField(controller: _schoolController, label: 'Escola', hint: 'Nome da escola', isRequired: true),
            const SizedBox(height: 16),
            CustomTextField(controller: _shiftController, label: 'Turno', hint: 'Período da aula', isRequired: true),
            const SizedBox(height: 16),
            CustomTextField(controller: _vanController, label: 'Van', hint: 'Apelido da van', isRequired: true),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              child: const Text('Cadastrar aluno'),
            ),
          ],
        ),
      ),
    );
  }
}