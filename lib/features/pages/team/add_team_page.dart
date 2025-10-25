import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_text_field.dart';
import '../../widgets/team/period_selector.dart';

class AddTeamPage extends StatefulWidget {
  const AddTeamPage({super.key});

  @override
  State<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  Period? _selectedPeriod = Period.morning; // Estado para o período selecionado

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Formulário válido, pegue os dados
      final teamName = _nameController.text;
      final teamCode = _codeController.text;
      final selectedPeriod = _selectedPeriod; // Já temos o enum

      // TODO: Implementar a lógica de envio para o backend
      print('Nome: $teamName');
      print('Código: $teamCode');
      print('Período: $selectedPeriod');

      // Exemplo de feedback e navegação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turma adicionada com sucesso! (Simulado)'),
          backgroundColor: AppPalette.green500,
        ),
      );
      Navigator.pop(context); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a cor de fundo do tema para consistência
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nova turma'),
        centerTitle: true,
        // Configurações da AppBar para combinar com a imagem
        backgroundColor: Colors.transparent, // Ou a cor de fundo da tela
        elevation: 0,
        // Cor dos ícones e texto (baseado no seu tema ou na imagem)
        foregroundColor: AppPalette.primary900,
      ),
      body: SingleChildScrollView(
        // Padding geral da tela
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Nome da Turma
              CustomTextField(
                controller: _nameController,
                label: 'Nome da turma',
                hint: 'Ex: Turma da tarde',
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome da turma é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24), // Espaçamento entre os campos

              // Campo Código
              CustomTextField(
                controller: _codeController,
                label: 'Código',
                hint: 'Ex: THGT65',
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Código é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24), // Espaçamento

              // Seletor de Período
              PeriodSelector(
                initialPeriod: _selectedPeriod,
                onPeriodSelected: (period) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
              ),
              const SizedBox(height: 40), // Espaço maior antes do botão

              // Botão Adicionar Turma
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800, // Cor do botão
                  foregroundColor: AppPalette.white, // Cor do texto
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bordas arredondadas
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16, // Tamanho da fonte
                    fontWeight: FontWeight.bold, // Negrito
                  ),
                ),
                child: const Text('Adicionar turma'),
              ),
              const SizedBox(height: 24), // Espaçamento no final
            ],
          ),
        ),
      ),
    );
  }
}