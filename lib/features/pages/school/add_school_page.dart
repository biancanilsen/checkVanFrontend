import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../model/address_suggestion.dart';
import '../../../provider/geocoding_provider.dart';
import '../../../provider/school_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddSchoolPage extends StatefulWidget {
  const AddSchoolPage({super.key});

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

  @override
  void initState() {
    super.initState();
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
    final success = await schoolProvider.createSchool(
      name: _nameController.text,
      address: fullAddress,
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
        _formKey.currentState?.reset();
        _nameController.clear();
        _addressController.clear();
        _numberController.clear();
        _morningLimitController.clear();
        _morningDepartureController.clear();
        _afternoonLimitController.clear();
        _afternoonDepartureController.clear();

        Navigator.pop(context);
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
              const Text(
                'Dados da Escola',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Preencha as informações para cadastrar uma nova escola.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppPalette.neutral600),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _nameController,
                label: 'Nome da Escola',
                hint: 'Digite o nome da escola',
                isRequired: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildAddressField(),
              const SizedBox(height: 24),
              const Text('Horários', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPalette.neutral800)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _morningLimitController,
                      label: 'Chegada (Manhã)',
                      hint: 'HH:mm',
                      onTap: () => _pickTime(context, _morningLimitController),
                      suffixIcon: Icons.access_time_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _morningDepartureController,
                      label: 'Saída (Manhã)',
                      hint: 'HH:mm',
                      onTap: () => _pickTime(context, _morningDepartureController),
                      suffixIcon: Icons.access_time_outlined,
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
                      suffixIcon: Icons.access_time_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _afternoonDepartureController,
                      label: 'Saída (Tarde)',
                      hint: 'HH:mm',
                      onTap: () => _pickTime(context, _afternoonDepartureController),
                      suffixIcon: Icons.access_time_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: schoolProvider.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: schoolProvider.isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                )
                    : const Text('Salvar Escola'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o campo de endereço com a funcionalidade de autocomplete.
  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppPalette.neutral900),
            children: [
              TextSpan(text: 'Endereço'),
              TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // --- AJUSTE: Adicionada uma Row para logradouro e número ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3, // Ocupa mais espaço
              child: TextFormField(
                controller: _addressController,
                focusNode: _addressFocusNode,
                decoration: const InputDecoration(hintText: 'Digite para buscar o endereço'),
                validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1, // Ocupa menos espaço
              child: TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(hintText: 'Nº'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),
        if (_showSuggestions)
          Container(
            height: 200,
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: _isAddressLoading
                ? const Center(child: CircularProgressIndicator())
                : _addressSuggestions.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Nenhum endereço encontrado.')))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _addressSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _addressSuggestions[index];
                return ListTile(
                  title: Text(suggestion.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(suggestion.addressDetails),
                  onTap: () {
                    _addressController.removeListener(_onAddressChanged);
                    setState(() {
                      _addressController.text = suggestion.fullDescription;
                      _showSuggestions = false;
                    });
                    _addressController.addListener(_onAddressChanged);
                    _addressFocusNode.unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}