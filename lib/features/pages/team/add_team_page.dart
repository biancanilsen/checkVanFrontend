import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../model/address_suggestion.dart';
import '../../../model/team_model.dart';
import '../../../provider/geocoding_provider.dart';
import '../../../provider/school_provider.dart';
import '../../../provider/team_provider.dart';
import '../../../provider/van_provider.dart';
import '../../widgets/button/primary_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/team/period_selector.dart';
import '../../widgets/utils/custom_dropdown_field.dart';
import '../../../utils/address_utils.dart';
import '../../widgets/utils/address_field.dart';

class AddTeamPage extends StatefulWidget {
  final Team? team;

  const AddTeamPage({
    super.key,
    this.team,
  });

  @override
  State<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();

  Period? _selectedPeriod;
  int? _selectedSchoolId;
  int? _selectedVanId;

  final _addressFocusNode = FocusNode();
  List<AddressSuggestion> _addressSuggestions = [];
  bool _isAddressLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;

  bool get isEditing => widget.team != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
      Provider.of<VanProvider>(context, listen: false).getVans();
    });

    if (isEditing) {
      final team = widget.team!;
      _nameController.text = team.name;
      _selectedSchoolId = team.schoolId;
      _selectedVanId = team.vanId;

      if (team.shift == 'morning') {
        _selectedPeriod = Period.morning;
      } else if (team.shift == 'afternoon') {
        _selectedPeriod = Period.afternoon;
      }

      final String fullAddress = team.address ?? '';
      bool addressParsed = false;

      final RegExp complexAddressRegex = RegExp(r'(,\s*)(\d+)(\s*-\s*)');
      final Match? complexMatch = complexAddressRegex.firstMatch(fullAddress);

      if (complexMatch != null && complexMatch.group(2) != null) {
        final String number = complexMatch.group(2)!;
        final String street = fullAddress.replaceFirst(
            RegExp(r',\s*' + number + r'\s*-\s*'),
            ' - '
        );
        _addressController.text = street;
        _numberController.text = number;
        addressParsed = true;
      }

      if (!addressParsed) {
        AddressUtils.splitAddressForEditing(
          fullAddress: fullAddress,
          streetController: _addressController,
          numberController: _numberController,
        );
      }
    }

    _addressController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _addressFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final pattern = _addressController.text.trim();
      if (pattern.length < 3) {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
            _addressSuggestions = [];
          });
        }
        return;
      }
      setState(() {
        _isAddressLoading = true;
        _showSuggestions = true;
      });

      try {
        final suggestions = await context.read<GeocodingProvider>().fetchSuggestions(pattern);
        if (mounted) {
          setState(() {
            _addressSuggestions = suggestions;
            _isAddressLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _addressSuggestions = [];
            _isAddressLoading = false;
          });
        }
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

  Future<void> _selectSuggestion(AddressSuggestion suggestion) async {
    _addressController.removeListener(_onAddressChanged);
    setState(() {
      _addressController.text = suggestion.fullDescription;
      _showSuggestions = false;
    });
    _addressController.addListener(_onAddressChanged);
    _addressFocusNode.unfocus();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a escola.'),
          backgroundColor: AppPalette.red500,
        ),
      );
      return;
    }

    final teamProvider = context.read<TeamProvider>();
    bool success;

    final String? shift = _selectedPeriod == Period.morning
        ? 'morning'
        : _selectedPeriod == Period.afternoon
        ? 'afternoon'
        : null;

    final fullAddress = '${_addressController.text}, ${_numberController.text}';

    if (isEditing) {
      success = await teamProvider.updateTeam(
        id: widget.team!.id,
        name: _nameController.text.trim(),
        schoolId: _selectedSchoolId!,
        address: fullAddress,
        shift: shift,
        vanId: _selectedVanId,
      );
    } else {
      success = await teamProvider.addTeam(
        name: _nameController.text.trim(),
        schoolId: _selectedSchoolId!,
        address: fullAddress,
        vanId: _selectedVanId,
        shift: shift,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Turma atualizada com sucesso!' : 'Turma adicionada com sucesso!'),
          backgroundColor: AppPalette.green500,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(teamProvider.error ?? 'Erro ao salvar turma.'),
          backgroundColor: AppPalette.red500,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schoolProvider = context.watch<SchoolProvider>();
    final vanProvider = context.watch<VanProvider>();
    final teamProvider = context.watch<TeamProvider>();

    final bool vanListContainsValue = vanProvider.vans.any(
            (v) => v.id == _selectedVanId
    );
    final int? effectiveVanId = vanListContainsValue ? _selectedVanId : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar turma' : 'Nova turma'),
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
                validator: (value) => (value == null || value.isEmpty) ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),

              AddressField(
                streetController: _addressController,
                numberController: _numberController,
                addressFocusNode: _addressFocusNode,
                showSuggestions: _showSuggestions,
                isAddressLoading: _isAddressLoading,
                addressSuggestions: _addressSuggestions,
                onSuggestionSelected: _selectSuggestion,
                streetValidator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                numberValidator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
              ),

              const SizedBox(height: 16),

              CustomDropdownField<int?>(
                label: 'Escola',
                hint: schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola',
                value: _selectedSchoolId,
                items: schoolProvider.schools
                    .map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: schoolProvider.isLoading
                    ? null
                    : (value) => setState(() => _selectedSchoolId = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              CustomDropdownField<int?>(
                label: 'Van',
                hint: vanProvider.isLoading ? 'Carregando vans...' : 'Selecione uma van',
                value: effectiveVanId,
                items: vanProvider.vans
                    .map((v) => DropdownMenuItem<int>(
                  value: v.id,
                  child: Text(v.nickname),
                ))
                    .toList(),
                onChanged: vanProvider.isLoading
                    ? null
                    : (value) => setState(() => _selectedVanId = value),
                validator: null,
              ),
              const SizedBox(height: 20),

              PeriodSelector(
                initialPeriod: _selectedPeriod,
                onPeriodSelected: (period) {
                  setState(() => _selectedPeriod = period);
                },
              ),
              const SizedBox(height: 40),

              if (isEditing)
                PrimaryButton(
                  text: 'Salvar Alterações',
                  onPressed: (teamProvider.isLoading) ? null : _submitForm,
                  isLoading: teamProvider.isLoading,
                )
              else
                ElevatedButton(
                  onPressed: (teamProvider.isLoading) ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  child: teamProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Adicionar turma'),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}