import 'dart:math'; // Placeholder for future backend call simulation
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
  Period? _selectedPeriod = Period.morning;
  bool _isGeneratingCode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() {
      _isGeneratingCode = true;
    });

    // TODO: Replace with actual backend call to generate the code
    await Future.delayed(const Duration(seconds: 1));
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    if (mounted) {
      setState(() {
        _codeController.text = code;
        _isGeneratingCode = false;
        _formKey.currentState?.validate();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final teamName = _nameController.text;
      final teamCode = _codeController.text;
      final selectedPeriod = _selectedPeriod;

      // TODO: Implementar a lógica de envio para o backend
      print('Nome: $teamName');
      print('Código: $teamCode');
      print('Período: $selectedPeriod');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turma adicionada com sucesso! (Simulado)'),
          backgroundColor: AppPalette.green500,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nova turma'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 24),

              // --- Código Field Row ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppPalette.neutral800,
                      ),
                      children: const [
                        TextSpan(text: 'Código'),
                        TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        // TODO - Transferir a responsabilidade de criar o código para o backend
                        child: TextFormField(
                          controller: _codeController,
                          readOnly: true, // Make the field read-only
                          decoration: InputDecoration(
                            hintText: 'Clique em Gerar', // Updated hint
                            border: inputDecorationTheme.border ?? const OutlineInputBorder(),
                            enabledBorder: inputDecorationTheme.enabledBorder?.copyWith(
                                borderSide: const BorderSide(color: AppPalette.neutral200) // Lighter border
                            ),
                            focusedBorder: inputDecorationTheme.focusedBorder,
                            errorBorder: inputDecorationTheme.errorBorder,
                            focusedErrorBorder: inputDecorationTheme.focusedErrorBorder,
                            filled: true,
                            fillColor: AppPalette.neutral100, // Lighter background
                            hintStyle: inputDecorationTheme.hintStyle,
                            contentPadding: inputDecorationTheme.contentPadding,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Gere um código'; // Updated validation message
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: ElevatedButton.icon(
                          icon: _isGeneratingCode
                              ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppPalette.neutral800,
                            ),
                          )
                              : const Icon(Icons.refresh, size: 20),
                          label: const Text('Gerar'),
                          onPressed: _isGeneratingCode ? null : _generateCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.neutral150,
                            foregroundColor: AppPalette.neutral800,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            minimumSize: const Size(0, 50), // Match input height roughly
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // --- End Código Field Row ---

              const SizedBox(height: 24),

              PeriodSelector(
                initialPeriod: _selectedPeriod,
                onPeriodSelected: (period) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800,
                  foregroundColor: AppPalette.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Adicionar turma'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

