import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../provider/school_provider.dart';
import '../widgets/custom_text_field.dart';

class SchoolPage extends StatefulWidget {
  const SchoolPage({super.key});

  @override
  State<SchoolPage> createState() => _SchoolPageState();
}

class _SchoolPageState extends State<SchoolPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _morningLimitController = TextEditingController();
  final _morningDepartureController = TextEditingController();
  final _afternoonLimitController = TextEditingController();
  final _afternoonDepartureController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _morningLimitController.dispose();
    _morningDepartureController.dispose();
    _afternoonLimitController.dispose();
    _afternoonDepartureController.dispose();
    super.dispose();
  }

  /// Exibe o seletor de tempo e atualiza o controller correspondente.
  Future<void> _pickTime(BuildContext context, TextEditingController controller) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Garante que o tema seja aplicado ao TimePicker
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      // Formata a hora no padrão "HH:mm" que o backend espera
      final formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  /// Submete o formulário para criar a nova escola.
  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final schoolProvider = context.read<SchoolProvider>();
    final success = await schoolProvider.createSchool(
      name: _nameController.text,
      address: _addressController.text,
      morningLimit: _morningLimitController.text,
      morningDeparture: _morningDepartureController.text,
      afternoonLimit: _afternoonLimitController.text,
      afternoonDeparture: _afternoonDepartureController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escola cadastrada com sucesso!'),
            backgroundColor: AppPalette.green500,
          ),
        );
        // Limpa os campos do formulário
        _formKey.currentState?.reset();
        _nameController.clear();
        _addressController.clear();
        _morningLimitController.clear();
        _morningDepartureController.clear();
        _afternoonLimitController.clear();
        _afternoonDepartureController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(schoolProvider.error ?? 'Ocorreu um erro desconhecido.'),
            backgroundColor: AppPalette.red500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no provider para atualizar o estado do botão (loading)
    final schoolProvider = context.watch<SchoolProvider>();

    return Scaffold(
      appBar: AppBar(
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
              const Text('Cadastro de Escola', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary900)),
              const SizedBox(height: 8),
              const Text('Preencha os dados da escola', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppPalette.neutral600)),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _nameController,
                label: 'Nome da Escola',
                hint: 'Digite o nome da escola',
                isRequired: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'Endereço',
                hint: 'Rua, bairro, número',
                isRequired: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Campos de Horário
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _morningLimitController,
                      label: 'Chegada (Manhã)',
                      hint: 'HH:mm',
                      onTap: () => _pickTime(context, _morningLimitController),
                      suffixIcon: Icons.access_time,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _morningDepartureController,
                      label: 'Saída (Manhã)',
                      hint: 'HH:mm',
                      onTap: () => _pickTime(context, _morningDepartureController),
                      suffixIcon: Icons.access_time,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _afternoonLimitController,
                      label: 'Chegada (Tarde)',
                      hint: 'HH:mm',
                      onTap: () => _pickTime(context, _afternoonLimitController),
                      suffixIcon: Icons.access_time,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _afternoonDepartureController,
                      label: 'Saída (Tarde)',
                      hint: 'HH:mm',
                      onTap: () => _pickTime(context, _afternoonDepartureController),
                      suffixIcon: Icons.access_time,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: schoolProvider.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                child: schoolProvider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Salvar Escola'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

