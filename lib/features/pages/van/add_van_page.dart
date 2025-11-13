import 'package:check_van_frontend/model/van_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../enum/snack_bar_type.dart';
import '../../../provider/van_provider.dart';
import '../../widgets/button/danger_outline_button.dart';
import '../../widgets/button/primary_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dialog/delete_van_dialog.dart';
import '../../widgets/van/custom_snackbar.dart';

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

  bool get isEditing => widget.van != null;
  bool _isDeleting = false;

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
        CustomSnackBar.show(
          context: context,
          label: isEditing ? 'Van atualizada com sucesso!' : 'Van cadastrada com sucesso!',
          type: SnackBarType.success,
        );

        Navigator.pop(context);
      } else {
        CustomSnackBar.show(
          context: context,
          label: vanProvider.error ?? 'Ocorreu um erro desconhecido.',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _handleDeleteVan() async {
    if (!isEditing) return;

    setState(() {
      _isDeleting = true;
    });

    final vanProvider = context.read<VanProvider>();
    bool success = false;

    try {
      success = await vanProvider.deleteVan(widget.van!.id);
    } catch (e) {
      success = false;
    }

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        Navigator.pop(context);
        CustomSnackBar.show(
          context: context,
          label: 'Van excluída com sucesso.',
          type: SnackBarType.success,
        );
      } else {
        CustomSnackBar.show(
          context: context,
          label: vanProvider.error ?? 'Erro ao excluir van.',
          type: SnackBarType.error,
        );
      }
    }

    if (mounted) {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  void _showDeleteConfirmationDialog() {
    if (!isEditing || widget.van == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return DeleteVanDialog(
              vanNickname: widget.van!.nickname,
              isLoading: _isDeleting,
              onConfirm: _handleDeleteVan,
            );
          },
        );
      },
    ).then((_) {
      if (_isDeleting) {
        setState(() {
          _isDeleting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vanProvider = context.watch<VanProvider>();

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

              PrimaryButton(
                text: isEditing ? 'Salvar Alterações' : 'Cadastrar Van',
                onPressed: vanProvider.isLoading ? null : _submitVan,
                isLoading: vanProvider.isLoading,
              ),
              const SizedBox(height: 24),
              if (isEditing)
                DangerOutlineButton(
                  text: 'Excluir van',
                  onPressed: _showDeleteConfirmationDialog,
                  isLoading: _isDeleting,
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}