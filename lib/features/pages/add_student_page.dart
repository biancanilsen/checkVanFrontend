import 'dart:async'; // Importado para usar o Timer (debounce)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../model/address_suggestion.dart';
import '../../provider/geocoding_provider.dart';
import '../../provider/school_provider.dart';
import '../../provider/student_provider.dart';
import '../widgets/custom_text_field.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();

  // --- NOVAS VARIÁVEIS DE ESTADO PARA O AUTOCOMPLETE ---
  final _addressFocusNode = FocusNode();
  List<AddressSuggestion> _addressSuggestions = [];
  bool _isAddressLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;

  // Variáveis de estado para os dados do formulário
  DateTime? _birthDate;
  String? _selectedGender;
  int? _selectedSchoolId;
  String? _selectedShiftGoing;
  String? _selectedShiftReturn;

  // Variáveis para guardar dados do endereço selecionado
  String? _selectedCity;
  String? _selectedState;
  String? _selectedCountry;
  double? _selectedLat;
  double? _selectedLon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });

    // --- CONFIGURAÇÃO DOS LISTENERS PARA O AUTOCOMPLETE ---
    _streetController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();

    // --- LIMPEZA DOS RECURSOS DO AUTOCOMPLETE ---
    _streetController.removeListener(_onAddressChanged);
    _streetController.dispose();
    _addressFocusNode.removeListener(_onFocusChanged);
    _addressFocusNode.dispose();
    _debounce?.cancel();

    _numberController.dispose();
    super.dispose();
  }

  // --- NOVA FUNÇÃO PARA BUSCAR SUGESTÕES COM DEBOUNCE ---
  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final pattern = _streetController.text;
      if (pattern.length < 3) {
        setState(() {
          _showSuggestions = false;
          _addressSuggestions = [];
        });
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

  // --- NOVA FUNÇÃO PARA CONTROLAR VISIBILIDADE DA LISTA AO PERDER O FOCO ---
  void _onFocusChanged() {
    if (!_addressFocusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }


  void _pickDate() async {
    // (O restante do seu código permanece o mesmo)
    // ...
    FocusScope.of(context).requestFocus(FocusNode());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2010),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _submitForm() async {
    // (O restante do seu código permanece o mesmo)
    // ...
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final fullAddress = '${_streetController.text}, ${_numberController.text}, ${_selectedCity ?? ''}, ${_selectedState ?? ''}, ${_selectedCountry ?? ''}';

    final studentProvider = context.read<StudentProvider>();
    final success = await studentProvider.addStudent(
      name: _nameController.text,
      birthDate: _birthDate!,
      gender: _selectedGender!,
      schoolId: _selectedSchoolId!,
      address: fullAddress,
      shiftGoing: _selectedShiftGoing!,
      shiftReturn: _selectedShiftReturn!,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno cadastrado com sucesso!'),
            backgroundColor: AppPalette.green500,
          ),
        );
        Navigator.pushReplacementNamed(context, '/students');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(studentProvider.error ?? 'Ocorreu um erro.'),
            backgroundColor: AppPalette.red500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // (O método build permanece praticamente o mesmo, pois a lógica foi movida para _buildAddressField)
    // ...
    final schoolProvider = context.watch<SchoolProvider>();
    final studentProvider = context.watch<StudentProvider>();
    const List<String> shiftOptions = ['Manhã', 'Tarde', 'Noite'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Aluno'),
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
              const Text('Dados do aluno', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary900)),
              const SizedBox(height: 8),
              const Text('Preencha os dados do aluno para realizar o cadastro', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppPalette.neutral600)),
              const SizedBox(height: 32),
              const Center(child: CircleAvatar(radius: 80, backgroundImage: AssetImage('assets/retratoCrianca.webp'))),
              const SizedBox(height: 32),
              CustomTextField(controller: _nameController, label: 'Nome', hint: 'Nome do aluno', isRequired: true, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _birthDateController, label: 'Data de nascimento', hint: 'dd/mm/aaaa', isRequired: true, onTap: _pickDate, suffixIcon: Icons.calendar_today, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Gênero',
                hint: 'Selecione',
                value: _selectedGender,
                items: ['Masculino', 'Feminino'].map((gender) => DropdownMenuItem(value: gender.toLowerCase() == 'masculino' ? 'male' : 'female', child: Text(gender))).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // --- CAMPO DE ENDEREÇO COM AUTOCOMPLETE ---
              _buildAddressField(),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Escola',
                hint: schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola',
                value: _selectedSchoolId,
                items: schoolProvider.schools.map((school) => DropdownMenuItem(value: school.id, child: Text(school.name))).toList(),
                onChanged: schoolProvider.isLoading ? null : (value) => setState(() => _selectedSchoolId = value as int?),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Turno Ida',
                hint: 'Período da aula',
                value: _selectedShiftGoing,
                items: shiftOptions.map((shift) => DropdownMenuItem(value: shift, child: Text(shift))).toList(),
                onChanged: (value) => setState(() => _selectedShiftGoing = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Turno Volta',
                hint: 'Período da aula',
                value: _selectedShiftReturn,
                items: shiftOptions.map((shift) => DropdownMenuItem(value: shift, child: Text(shift))).toList(),
                onChanged: (value) => setState(() => _selectedShiftReturn = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: studentProvider.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                child: studentProvider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Cadastrar Aluno'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODO _buildAddressField TOTALMENTE REESCRITO ---
  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label do campo
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

        // Campos de Logradouro e Número
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _streetController,
                focusNode: _addressFocusNode,
                decoration: const InputDecoration(hintText: 'Logradouro'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obrigatório';
                  // if (_selectedLat == null) return 'Selecione um endereço da lista';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(hintText: 'Nº'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),

        // --- LISTA DE SUGESTÕES (CONDICIONAL) ---
        if (_showSuggestions)
          Container(
            height: _isAddressLoading || _addressSuggestions.isNotEmpty ? 200 : 50,
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                )
              ],
            ),
            child: _isAddressLoading
                ? const Center(child: CircularProgressIndicator())
                : _addressSuggestions.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: Text('Nenhum endereço encontrado.')),
            )
                : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _addressSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _addressSuggestions[index];
                return ListTile(
                  title: Text(suggestion.displayName),
                  subtitle: Text(suggestion.addressDetails),
                  onTap: () {
                    _streetController.removeListener(_onAddressChanged);
                    setState(() {
                      _streetController.text = suggestion.displayName;
                      _selectedCity = suggestion.city;
                      _selectedState = suggestion.state;
                      _selectedCountry = suggestion.country;
                      _selectedLat = suggestion.lat;
                      _selectedLon = suggestion.lon;
                      _showSuggestions = false;
                    });
                    _streetController.addListener(_onAddressChanged);
                    _addressFocusNode.unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
  }) {
    // (O restante do seu código permanece o mesmo)
    // ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            children: [
              TextSpan(text: label),
              const TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(hint, style: Theme.of(context).inputDecorationTheme.hintStyle),
          decoration: const InputDecoration(),
          borderRadius: BorderRadius.circular(12.0),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}