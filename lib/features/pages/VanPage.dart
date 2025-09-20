import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter/services.dart';

class VanPage extends StatefulWidget {
  const VanPage({super.key});

  @override
  State<VanPage> createState() => _VanPageState();
}

class _VanPageState extends State<VanPage> {
  // Controllers para gerenciar o estado dos campos do formulário
  final _nicknameController = TextEditingController();
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController(); // Controller para o novo campo de texto
  final _schoolNameController = TextEditingController();
  final _schoolAddressController = TextEditingController();
  final _schoolPhoneController = TextEditingController();
  // A variável _selectedCapacity foi removida

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _capacityController.dispose(); // Dispose do novo controller
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
    _schoolPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Cabeçalho da página
            const Text(
              'Cadastro da Van',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre a van e vincule uma escola',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppPalette.neutral600,
              ),
            ),
            const SizedBox(height: 32),

            // Formulário da Van
            CustomTextField(
              controller: _nicknameController,
              label: 'Apelido da van',
              hint: 'Ex: Van Branca',
              isRequired: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _plateController,
              label: 'Placa',
              hint: 'Digite a placa',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Campo de passageiros alterado para CustomTextField
            CustomTextField(
              controller: _capacityController,
              label: 'Passageiros',
              hint: 'Digite a capacidade de passageiros',
              isRequired: true,
              keyboardType: TextInputType.number, // Define o teclado para numérico
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Permite apenas a digitação de números
              ],
            ),
            const SizedBox(height: 24),

            // Botão "Adicionar Escola"
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Adicionar escola'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: AppPalette.primary900,
                side: const BorderSide(color: AppPalette.primary900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Borda bem arredondada
                ),
              ),
              onPressed: () {
                // Lógica para adicionar uma nova escola (pode abrir outro modal/página)
              },
            ),
            const SizedBox(height: 24),

            // Formulário da Escola
            CustomTextField(
              controller: _schoolNameController,
              label: 'Escola',
              hint: 'Nome da escola',
              isRequired: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _schoolAddressController,
              label: 'Endereço',
              hint: 'Rua, bairro, número',
              isRequired: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _schoolPhoneController,
              label: 'Telefone',
              hint: 'Digite o telefone',
              isRequired: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}