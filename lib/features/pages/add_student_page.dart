import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart'; // Importe seu AppColors

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  // Seus controllers continuam os mesmos
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _schoolController = TextEditingController();
  final _shiftController = TextEditingController();
  final _vanController = TextEditingController();
  String? _selectedGender;

  void _pickDate() async {
    FocusScope.of(context).requestFocus(FocusNode());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Data inicial ao abrir
      firstDate: DateTime(1920),  // Data mais antiga permitida
      lastDate: DateTime.now(),   // Data mais recente permitida (hoje)
      locale: const Locale('pt', 'BR'), // Garante que o seletor esteja em português
    );

    if (pickedDate != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        // Você também pode querer guardar o objeto DateTime em uma variável de estado se precisar dele
        // _birthDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    // A limpeza dos controllers continua a mesma
    super.dispose();
  }

  /// Widget auxiliar ATUALIZADO para criar os campos de texto com rótulo estilizado
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? suffixIcon,
    VoidCallback? onTap,
    bool isRequired = false, // Novo parâmetro para indicar se é obrigatório
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Usando RichText para estilizar o asterisco
        RichText(
          text: TextSpan(
            // Estilo padrão para o texto do rótulo
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87, // Cor padrão do texto
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red, // Cor apenas para o asterisco
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dados do aluno',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                 color: AppPalette.primary900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preencha os dados do aluno para realizar o cadastro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppPalette.neutral900,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),

            // Avatar
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppPalette.neutral200,
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: AppPalette.neutral400,
                ),
              ),
            ),
            const SizedBox(height: 6),
            _buildTextField(controller: _nameController, label: 'Nome', hint: 'Nome do aluno', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    children: [
                      TextSpan(text: 'Gênero'),
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
                  decoration: InputDecoration(
                    filled: true,
                    // fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Masculino')),
                    DropdownMenuItem(value: 'female', child: Text('Feminino')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) => value == null ? 'O gênero é obrigatório' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: _addressController, label: 'Endereço', hint: 'Rua, bairro, número', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(controller: _schoolController, label: 'Escola', hint: 'Nome da escola', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(controller: _shiftController, label: 'Turno', hint: 'Período da aula', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(controller: _vanController, label: 'Van', hint: 'Apelido da van', isRequired: true),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              child: const Text('Cadastrar aluno'),
            ),
          ],
        ),
      ),
    );
  }
}