import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../model/address_suggestion.dart';
import '../../../provider/geocoding_provider.dart';
import '../../../provider/school_provider.dart';
import '../../../provider/student_provider.dart';
import '../../widgets/custom_text_field.dart';

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

  final _addressFocusNode = FocusNode();
  List<AddressSuggestion> _addressSuggestions = [];
  bool _isAddressLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;
  // As variáveis _selectedCity, _selectedState, _selectedCountry, _selectedLat e _selectedLon foram REMOVIDAS.

  // Variáveis de estado para os dados do formulário
  DateTime? _birthDate;
  String? _selectedGender;
  int? _selectedSchoolId;
  String? _selectedShiftGoing;
  String? _selectedShiftReturn;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // NOVO: Crie uma função para selecionar a imagem da galeria
  Future<void> _pickImage() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Opcional: comprime a imagem para economizar dados
        maxWidth: 800,   // Opcional: redimensiona a imagem
      );
      if (selectedImage != null) {
        setState(() {
          _imageFile = selectedImage;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  // ATUALIZE o método _submitForm para passar o arquivo da imagem
  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final fullAddress = '${_streetController.text}, ${_numberController.text}';

    final studentProvider = context.read<StudentProvider>();
    final success = await studentProvider.addStudent(
      name: _nameController.text,
      birthDate: _birthDate!,
      gender: _selectedGender!,
      schoolId: _selectedSchoolId!,
      address: fullAddress,
      shiftGoing: _selectedShiftGoing!,
      shiftReturn: _selectedShiftReturn!,
      imageFile: _imageFile, // NOVO: Passe o arquivo da imagem para o provider
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });

    _streetController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _streetController.dispose();
    _numberController.dispose();

    _addressFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final pattern = _streetController.text;
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

  void _pickDate() async {
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

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();
    final studentProvider = context.watch<StudentProvider>();
    const List<String> shiftOptions = ['Manhã', 'Tarde', 'Noite'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text('Dados do aluno', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary800)),
              const SizedBox(height: 8),
              const Text('Preencha os dados para realizar o cadastro', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppPalette.neutral600)),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _pickImage, // Chama a função para escolher a imagem
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade200,
                    // Mostra a imagem selecionada ou a imagem padrão
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : const AssetImage('assets/profile.png') as ImageProvider,
                    child: _imageFile == null
                        ? Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppPalette.primary900,
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomTextField(controller: _nameController, label: 'Nome', hint: 'Nome do aluno', isRequired: true, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _birthDateController, label: 'Data de nascimento', hint: 'dd/mm/aaaa', isRequired: true, onTap: _pickDate, suffixIcon: Icons.calendar_today, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Gênero', hint: 'Selecione', value: _selectedGender,
                items: ['Masculino', 'Feminino'].map((g) => DropdownMenuItem(value: g == 'Masculino' ? 'male' : 'female', child: Text(g))).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              _buildAddressField(), // Campo de endereço com autocomplete
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Escola',
                hint: schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola',
                value: _selectedSchoolId,
                items: schoolProvider.schools.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: schoolProvider.isLoading ? null : (value) => setState(() => _selectedSchoolId = value as int?),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Turno Ida', hint: 'Período da aula', value: _selectedShiftGoing,
                items: shiftOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) => setState(() => _selectedShiftGoing = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Turno Volta', hint: 'Período da aula', value: _selectedShiftReturn,
                items: shiftOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) => setState(() => _selectedShiftReturn = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: studentProvider.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800, foregroundColor: Colors.white,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _streetController,
                focusNode: _addressFocusNode,
                decoration: const InputDecoration(hintText: 'Logradouro'),
                validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
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
        // Container que exibe as sugestões de endereço
        if (_showSuggestions)
          Container(
            height: 200,
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 8)],
            ),
            child: _isAddressLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _addressSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _addressSuggestions[index];
                return ListTile(
                  title: Text(suggestion.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(suggestion.addressDetails),
                  onTap: () {
                    // LÓGICA SIMPLIFICADA: Apenas preenche o campo de texto.
                    _streetController.removeListener(_onAddressChanged);
                    setState(() {
                      // Usamos a descrição completa para o campo de rua.
                      _streetController.text = suggestion.fullDescription;
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

  // Widget auxiliar para criar os dropdowns de forma consistente
  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
  }) {
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