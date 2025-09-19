
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  // Controllers para os campos do formulário
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _schoolController = TextEditingController();
  final _shiftController = TextEditingController();
  final _vanController = TextEditingController();

  @override
  void dispose() {
    // Limpeza dos controllers
    _nameController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _schoolController.dispose();
    _shiftController.dispose();
    _vanController.dispose();
    super.dispose();
  }

  // Widget auxiliar para criar os campos de texto com o rótulo em cima
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Aluno'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho
            const Text(
              'Dados do aluno',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preencha os dados do aluno para realizar o cadastro',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Avatar
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, size: 80, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 32),

            // Formulário
            _buildTextField(controller: _nameController, label: 'Nome *', hint: 'Nome do aluno'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _birthDateController,
              label: 'Data de nascimento *',
              hint: 'dd/mm/aaaa',
              suffixIcon: Icons.calendar_today,
              onTap: () { /* Lógica para abrir o DatePicker (removida) */ },
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: _genderController, label: 'Gênero *', hint: ''),
            const SizedBox(height: 16),
            _buildTextField(controller: _addressController, label: 'Endereço *', hint: 'Rua, bairro, número'),
            const SizedBox(height: 16),
            _buildTextField(controller: _schoolController, label: 'Escola *', hint: 'Nome da escola'),
            const SizedBox(height: 16),
            _buildTextField(controller: _shiftController, label: 'Turno *', hint: 'Período da aula'),
            const SizedBox(height: 16),
            _buildTextField(controller: _vanController, label: 'Van *', hint: 'Apelido da van'),
            const SizedBox(height: 32),

            // Botão de Cadastro
            ElevatedButton(
              onPressed: () {}, // Sem ação, como solicitado
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cadastrar Aluno', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}