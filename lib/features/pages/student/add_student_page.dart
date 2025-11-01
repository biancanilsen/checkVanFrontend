import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../model/address_suggestion.dart';
import '../../../model/student_model.dart';
import '../../../provider/geocoding_provider.dart';
import '../../../provider/school_provider.dart';
import '../../../provider/student_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/utils/address_field.dart';
import '../../widgets/utils/custom_dropdown_field.dart';

class AddStudentPage extends StatefulWidget {
  final Student? student;

  const AddStudentPage({
    super.key,
    this.student,
  });

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

  DateTime? _birthDate;
  String? _selectedGender;
  int? _selectedSchoolId;
  String? _selectedShiftGoing;
  String? _selectedShiftReturn;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });

    // 3. PREENCHA OS CAMPOS SE ESTIVER EDITANDO
    if (isEditing) {
      final student = widget.student!;
      _nameController.text = student.name;
      _birthDate = student.birthDate;
      _birthDateController.text = DateFormat('dd/MM/yyyy').format(student.birthDate);
      _selectedGender = student.gender;
      _selectedSchoolId = student.schoolId;
      _selectedShiftGoing = student.shiftGoing;
      _selectedShiftReturn = student.shiftReturn;

      // --- LÓGICA DE ENDEREÇO CORRIGIDA ---
      // TODO - rever isso do endereço pois o campo de numero fica vazio ao editar
      final String fullAddress = student.address;
      try {
        int lastCommaIndex = fullAddress.lastIndexOf(',');
        if (lastCommaIndex != -1) {
          // Encontrou uma vírgula. Vamos verificar.
          String potentialStreet = fullAddress.substring(0, lastCommaIndex).trim();
          String potentialNumber = fullAddress.substring(lastCommaIndex + 1).trim();

          // Tenta converter o 'potentialNumber' para um número.
          if (int.tryParse(potentialNumber) != null) {
            // SUCESSO! É um número. O formato é "Rua, Número"
            _streetController.text = potentialStreet;
            _numberController.text = potentialNumber;
          } else {
            // FALHA! Não é um número. (ex: "Blumen").
            // Assumimos que é um endereço antigo. Coloque tudo na rua.
            _streetController.text = fullAddress;
            _numberController.text = ''; // Deixe o número em branco
          }
        } else {
          // Não há vírgula. Coloque tudo no campo de rua.
          _streetController.text = fullAddress;
          _numberController.text = '';
        }
      } catch (e) {
        // Fallback para qualquer outro erro
        _streetController.text = fullAddress;
        _numberController.text = '';
      }
      // --- FIM DA LÓGICA CORRIGIDA ---
    }

    // Adiciona os listeners DEPOIS que os valores iniciais foram definidos.
    _streetController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
  }

  // ... (suas funções dispose, _pickImage, _submitForm, _pickDate, etc. permanecem iguais)
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

  Future<void> _pickImage() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
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

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final fullAddress = '${_streetController.text}, ${_numberController.text}';
    final studentProvider = context.read<StudentProvider>();

    bool success;

    if (isEditing) {
      success = await studentProvider.updateStudent(
        id: widget.student!.id,
        name: _nameController.text,
        birthDate: _birthDate!,
        gender: _selectedGender!,
        schoolId: _selectedSchoolId!,
        address: fullAddress,
        shiftGoing: _selectedShiftGoing!,
        shiftReturn: _selectedShiftReturn!,
        // TODO - Salvar a imagem quando atualiza o aluno
        // imageProfile: _imageFile,
      );
    } else {
      success = await studentProvider.addStudent(
        name: _nameController.text,
        birthDate: _birthDate!,
        gender: _selectedGender!,
        schoolId: _selectedSchoolId!,
        address: fullAddress,
        shiftGoing: _selectedShiftGoing!,
        shiftReturn: _selectedShiftReturn!,
        imageFile: _imageFile,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Aluno atualizado com sucesso!' : 'Aluno cadastrado com sucesso!'),
            backgroundColor: AppPalette.green500,
          ),
        );
        Navigator.pop(context);
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

  // 2. CRIE A FUNÇÃO DE CALLBACK PARA O ADDRESS_FIELD
  void _onSuggestionSelected(AddressSuggestion suggestion) {
    _streetController.removeListener(_onAddressChanged);
    setState(() {
      _streetController.text = suggestion.fullDescription;
      _showSuggestions = false;
    });
    _streetController.addListener(_onAddressChanged);
    _addressFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final Map<String, String> shiftOptions = {
      'morning': 'Manhã',
      'afternoon': 'Tarde',
      'night': 'Noite',
    };

    // --- CORREÇÃO APLICADA AQUI ---
    // 1. Verificamos se a lista de escolas (do provider) já contém o ID
    //    que temos no nosso estado (_selectedSchoolId).
    final bool schoolListContainsValue = schoolProvider.schools.any(
            (s) => s.id == _selectedSchoolId
    );

    // 2. Só passamos o ID para o Dropdown (value) se ele já existir na lista.
    //    Caso contrário, passamos null para evitar o erro.
    final int? effectiveSchoolId = schoolListContainsValue ? _selectedSchoolId : null;
    // --- FIM DA CORREÇÃO ---

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Aluno' : 'Cadastrar Aluno'),
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
              // ... (Todo o seu layout de Título, Imagem, Nome, Data, Gênero, etc. continua igual)
              const SizedBox(height: 16),
              Text(
                isEditing ? 'Editar Aluno' : 'Dados do aluno',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary800),
              ),
              const SizedBox(height: 8),
              Text(
                isEditing ? 'Altere os dados necessários' : 'Preencha os dados para realizar o cadastro',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppPalette.neutral600),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : (isEditing && widget.student!.image_profile != null
                        ? NetworkImage(widget.student!.image_profile!)
                        : const AssetImage('assets/profile.png')) as ImageProvider,
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

              CustomDropdownField<String>(
                label: 'Gênero', hint: 'Selecione', value: _selectedGender,
                items: ['Masculino', 'Feminino'].map((g) => DropdownMenuItem(value: g == 'Masculino' ? 'male' : 'female', child: Text(g))).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              AddressField(
                streetController: _streetController,
                numberController: _numberController,
                addressFocusNode: _addressFocusNode,
                showSuggestions: _showSuggestions,
                isAddressLoading: _isAddressLoading,
                addressSuggestions: _addressSuggestions,
                onSuggestionSelected: _onSuggestionSelected,
                streetValidator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
                numberValidator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // 3. USE O NOVO 'effectiveSchoolId' AQUI
              CustomDropdownField<int>(
                label: 'Escola',
                hint: schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola',
                value: effectiveSchoolId, // Use a variável corrigida
                items: schoolProvider.schools.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: schoolProvider.isLoading ? null : (value) => setState(() => _selectedSchoolId = value as int?),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              CustomDropdownField<String>(
                label: 'Turno Ida',
                hint: 'Período da aula',
                value: _selectedShiftGoing,
                items: shiftOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key, // "morning"
                    child: Text(entry.value), // "Manhã"
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedShiftGoing = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              CustomDropdownField<String>(
                label: 'Turno Volta',
                hint: 'Período da aula',
                value: _selectedShiftReturn,
                items: shiftOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key, // "morning"
                    child: Text(entry.value), // "Manhã"
                  );
                }).toList(),
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
                    : Text(isEditing ? 'Salvar Alterações' : 'Cadastrar Aluno'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}