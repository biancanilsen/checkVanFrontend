import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../enum/snack_bar_type.dart';
import '../../../model/address_suggestion.dart';
import '../../../model/school_model.dart';
import '../../../provider/geocoding_provider.dart';
import '../../../provider/school_provider.dart';
import '../../../utils/address_utils.dart';
import '../../widgets/button/danger_outline_button.dart';
import '../../widgets/button/primary_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dialog/delete_school_dialog.dart';
import '../../widgets/school/add_school_header.dart';
import '../../widgets/school/school_address_section.dart';
import '../../widgets/school/school_schedule_section.dart';
import '../../widgets/van/custom_snackbar.dart';

class AddSchoolPage extends StatefulWidget {
  final School? school;

  const AddSchoolPage({
    super.key,
    this.school,
  });

  @override
  State<AddSchoolPage> createState() => _AddSchoolPageState();
}

class _AddSchoolPageState extends State<AddSchoolPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _morningLimitController = TextEditingController();
  final _morningDepartureController = TextEditingController();
  final _afternoonLimitController = TextEditingController();
  final _afternoonDepartureController = TextEditingController();

  final _addressFocusNode = FocusNode();
  List<AddressSuggestion> _addressSuggestions = [];
  bool _isAddressLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;

  bool get isEditing => widget.school != null;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final school = widget.school!;
      _nameController.text = school.name;

      AddressUtils.splitAddressForEditing(
        fullAddress: school.address,
        streetController: _addressController,
        numberController: _numberController,
      );

      _morningLimitController.text = school.morningLimit ?? '';
      _morningDepartureController.text = school.morningDeparture ?? '';
      _afternoonLimitController.text = school.afternoonLimit ?? '';
      _afternoonDepartureController.text = school.afternoonDeparture ?? '';
    }

    _addressController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _morningLimitController.dispose();
    _morningDepartureController.dispose();
    _afternoonLimitController.dispose();
    _afternoonDepartureController.dispose();
    _addressFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final pattern = _addressController.text;
      if (pattern.length < 3) {
        if (mounted) setState(() => _showSuggestions = false);
        return;
      }
      setState(() {
        _isAddressLoading = true;
        _showSuggestions = true;
      });
      final suggestions = await context.read<GeocodingProvider>().fetchSuggestions(pattern);
      if (mounted) {
        setState(() {
          _addressSuggestions = suggestions;
          _isAddressLoading = false;
        });
      }
    });
  }

  void _onFocusChanged() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_addressFocusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  void _handleSuggestionSelected(AddressSuggestion suggestion) {
    _addressController.removeListener(_onAddressChanged);
    setState(() {
      _addressController.text = suggestion.fullDescription;
      _showSuggestions = false;
    });
    _addressController.addListener(_onAddressChanged);
    _addressFocusNode.unfocus();
  }

  Future<void> _pickTime(BuildContext context, TextEditingController controller) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final fullAddress = '${_addressController.text}, ${_numberController.text}';
    final schoolProvider = context.read<SchoolProvider>();

    bool success;

    if (isEditing) {
      success = await schoolProvider.updateSchool(
        id: widget.school!.id,
        name: _nameController.text,
        address: fullAddress,
        morningLimit: _morningLimitController.text,
        morningDeparture: _morningDepartureController.text,
        afternoonLimit: _afternoonLimitController.text,
        afternoonDeparture: _afternoonDepartureController.text,
      );
    } else {
      success = await schoolProvider.createSchool(
        name: _nameController.text,
        address: fullAddress,
        morningLimit: _morningLimitController.text,
        morningDeparture: _morningDepartureController.text,
        afternoonLimit: _afternoonLimitController.text,
        afternoonDeparture: _afternoonDepartureController.text,
      );
    }

    if (mounted) {
      if (success) {
        CustomSnackBar.show(
          context: context,
          label: isEditing ? 'Escola atualizada com sucesso!' : 'Escola cadastrada com sucesso!',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      } else {
        CustomSnackBar.show(
          context: context,
          label: schoolProvider.error ?? 'Ocorreu um erro desconhecido.',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _handleDeleteSchool() async {
    if (!isEditing) return;

    setState(() {
      _isDeleting = true;
    });

    final schoolProvider = context.read<SchoolProvider>();
    bool success = false;

    try {
      success = await schoolProvider.deleteSchool(widget.school!.id);
    } catch (e) {
      success = false;
    }

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        Navigator.pop(context);
        CustomSnackBar.show(
          context: context,
          label: 'Escola excluída com sucesso.',
          type: SnackBarType.success,
        );
      } else {
        CustomSnackBar.show(
          context: context,
          label: schoolProvider.error ?? 'Erro ao excluir escola.',
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
    if (!isEditing || widget.school == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return DeleteSchoolDialog(
              schoolName: widget.school!.name,
              isLoading: _isDeleting,
              onConfirm: _handleDeleteSchool,
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
    final schoolProvider = context.watch<SchoolProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AddSchoolHeader(isEditing: isEditing),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _nameController,
                label: 'Nome da Escola',
                hint: 'Digite o nome da escola',
                isRequired: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              SchoolAddressSection(
                addressController: _addressController,
                numberController: _numberController,
                addressFocusNode: _addressFocusNode,
                showSuggestions: _showSuggestions,
                isLoading: _isAddressLoading,
                suggestions: _addressSuggestions,
                onSuggestionSelected: _handleSuggestionSelected,
              ),

              const SizedBox(height: 24),

              SchoolScheduleSection(
                morningLimitController: _morningLimitController,
                morningDepartureController: _morningDepartureController,
                afternoonLimitController: _afternoonLimitController,
                afternoonDepartureController: _afternoonDepartureController,
                onPickTime: (controller) => _pickTime(context, controller),
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: isEditing ? 'Salvar Alterações' : 'Cadastrar Escola',
                onPressed: schoolProvider.isLoading ? null : _submitForm,
                isLoading: schoolProvider.isLoading,
              ),
              const SizedBox(height: 24),

              if (isEditing)
                DangerOutlineButton(
                  text: 'Excluir escola',
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