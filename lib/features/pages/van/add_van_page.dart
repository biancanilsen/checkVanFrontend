import 'package:check_van_frontend/model/van_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../provider/van_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddVanPage extends StatefulWidget {
  final Van? van;

  const AddVanPage({
    super.key,
    this.van,
  });

  @override
  State<AddVanPage> createState() => _AddVanPageState();
}

class _AddVanPageState extends State<AddVanPage> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();

  // 3. Getter para modo de edição
  bool get isEditing => widget.van != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final van = widget.van!;
      _nicknameController.text = van.nickname;
      _plateController.text = van.plate;
      _capacityController.text = van.capacity.toString();
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submitVan() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final vanProvider = context.read<VanProvider>();
    bool success;

    if (isEditing) {
      success = await vanProvider.updateVan(
        id: widget.van!.id,
        nickname: _nicknameController.text,
        plate: _plateController.text,
        capacity: int.tryParse(_capacityController.text) ?? 0,
      );
    } else {
      success = await vanProvider.createVan(
        nickname: _nicknameController.text,
        plate: _plateController.text,
        capacity: int.tryParse(_capacityController.text) ?? 0,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Van atualizada com sucesso!' : 'Van cadastrada com sucesso!'),
            backgroundColor: AppPalette.green500,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vanProvider.error ?? 'Ocorreu um erro desconhecido.'),
            backgroundColor: AppPalette.red500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vanProvider = context.watch<VanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Van' : 'Nova Van'),
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
              Text(
                isEditing ? 'Editar Van' : 'Cadastro da Van',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary800),
              ),
              const SizedBox(height: 8),
              Text(
                isEditing ? 'Atualize os dados da van' : 'Cadastre os dados da sua van',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppPalette.neutral600),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _nicknameController,
                label: 'Apelido da van',
                hint: 'Ex: Van Branca',
                isRequired: true,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _plateController,
                label: 'Placa',
                hint: 'Digite a placa',
                isRequired: true,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _capacityController,
                label: 'Passageiros',
                hint: 'Digite a capacidade',
                isRequired: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if ((int.tryParse(value) ?? 0) <= 0) return 'A capacidade deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: vanProvider.isLoading ? null : _submitVan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                child: vanProvider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isEditing ? 'Salvar Alterações' : 'Salvar Van'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}