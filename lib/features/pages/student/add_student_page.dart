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
import '../../../provider/team_provider.dart';
import '../../../utils/address_utils.dart';
import '../../../utils/launcher_utils.dart';
import '../../../utils/user_session.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/student/guardian_card.dart';
import '../../widgets/utils/address_field.dart';
import '../../widgets/utils/custom_dropdown_field.dart';

class AddStudentPage extends StatefulWidget {
  final Student? student;
  final bool isJustViewState;

  const AddStudentPage({super.key, this.student, this.isJustViewState = false});

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

  int? _selectedTeamId;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _userRole;
  bool _isLoadingRole = true;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
      Provider.of<TeamProvider>(context, listen: false).getTeams();
    });

    if (isEditing) {
      final student = widget.student!;
      _nameController.text = student.name;
      _birthDate = student.birthDate;
      _birthDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(student.birthDate);
      _selectedGender = student.gender;
      _selectedSchoolId = student.schoolId;
      _selectedShiftGoing = student.shiftGoing;
      _selectedShiftReturn = student.shiftReturn;
      // 4. Preencha a turma (se o aluno tiver uma)
      // Você precisará atualizar seu StudentModel para incluir o 'team_id' ou 'teams'
      // Assumindo que student.teamId ou student.teams.first.id exista
      _selectedTeamId = student.teamId;

      AddressUtils.splitAddressForEditing(
        fullAddress: student.address,
        streetController: _streetController,
        numberController: _numberController,
      );
    }

    _streetController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
  }

  Future<void> _loadUserRole() async {
    final user = await UserSession.getUser();
    if (mounted) {
      setState(() {
        _userRole = user?.role;
        _isLoadingRole = false;
      });
    }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
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
        shiftGoing: _selectedShiftGoing ?? '',
        shiftReturn: _selectedShiftReturn ?? '',
        imageFile: _imageFile,
        teamId: _selectedTeamId,
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
            content: Text(
              isEditing
                  ? 'Aluno atualizado com sucesso!'
                  : 'Aluno cadastrado com sucesso!',
            ),
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
      final suggestions = await context
          .read<GeocodingProvider>()
          .fetchSuggestions(pattern);
      if (mounted) {
        setState(() {
          _addressSuggestions = suggestions;
          _isAddressLoading = false;
        });
      }
    });
  }

  void _onFocusChanged() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      if (_addressFocusNode.hasFocus) {
        if (_streetController.text.length >= 3) {
          setState(() {
            _showSuggestions = true;
          });
          _onAddressChanged();
        }
      } else {
        setState(() {
          _showSuggestions = false;
        });
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
    if (_isLoadingRole) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final bool isGuardian = _userRole == 'guardian';
    final bool isDriver = _userRole == 'driver';
    final bool canEditSensitive = isGuardian;
    final bool canEditLogistic = isDriver;
    final bool isReadOnlyMode = widget.isJustViewState;
    final schoolProvider = context.watch<SchoolProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final teamProvider = context.watch<TeamProvider>();

    final Map<String?, String> shiftOptions = {
      null: 'Não informado',
      'morning': 'Manhã',
      'afternoon': 'Tarde',
      'night': 'Noite',
    };

    final bool schoolListContainsValue = schoolProvider.schools.any(
      (s) => s.id == _selectedSchoolId,
    );
    final int? effectiveSchoolId =
        schoolListContainsValue ? _selectedSchoolId : null;

    final bool teamListContainsValue = teamProvider.teams.any(
      (t) => t.id == _selectedTeamId,
    );
    final int? effectiveTeamId = teamListContainsValue ? _selectedTeamId : null;

    final String? effectiveShiftGoing =
        shiftOptions.containsKey(_selectedShiftGoing)
            ? _selectedShiftGoing
            : null;

    final String? effectiveShiftReturn =
        shiftOptions.containsKey(_selectedShiftReturn)
            ? _selectedShiftReturn
            : null;

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
              Text(
                isGuardian
                    ? (isEditing && !isReadOnlyMode ? 'Editar Aluno' : 'Cadastrar Aluno')
                    : 'Visulizar Aluno',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.primary800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isGuardian
                    ? (isEditing
                        ? 'Altere os dados necessários'
                        : 'Preencha os dados para realizar o cadastro')
                    : 'Visulize as informações do aluno',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppPalette.neutral600,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap:
                      canEditSensitive || _pickImage == null
                          ? _pickImage
                          : null,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        _imageFile != null
                            ? FileImage(File(_imageFile!.path))
                            : (isEditing &&
                                        widget.student!.image_profile != null
                                    ? NetworkImage(
                                      widget.student!.image_profile!,
                                    )
                                    : const AssetImage('assets/profile.png'))
                                as ImageProvider,
                    child:
                        ((_imageFile == null || canEditSensitive) && !isReadOnlyMode)
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

              CustomTextField(
                controller: _nameController,
                label: 'Nome',
                hint: 'Nome do aluno',
                isRequired: true,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                readOnly: !canEditSensitive || isReadOnlyMode,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _birthDateController,
                label: 'Data de nascimento',
                hint: 'dd/mm/aaaa',
                isRequired: true,
                onTap: _pickDate,
                suffixIcon: Icons.calendar_today,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                readOnly: !canEditSensitive || isReadOnlyMode,
              ),
              const SizedBox(height: 16),

              CustomDropdownField<String?>(
                label: 'Gênero',
                hint: 'Selecione',
                value: _selectedGender,
                items:
                    ['Masculino', 'Feminino']
                        .map(
                          (g) => DropdownMenuItem(
                            value: g == 'Masculino' ? 'male' : 'female',
                            child: Text(g),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
                readOnly: !canEditSensitive || isReadOnlyMode,
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
                streetValidator:
                    (value) =>
                        (value == null || value.isEmpty) ? 'Obrigatório' : null,
                numberValidator:
                    (value) =>
                        (value == null || value.isEmpty) ? 'Obrigatório' : null,
                readOnly: isReadOnlyMode,
              ),
              const SizedBox(height: 16),

              CustomDropdownField<int?>(
                label: 'Escola',
                hint:
                    schoolProvider.isLoading
                        ? 'Carregando...'
                        : 'Selecione a escola',
                value: effectiveSchoolId,
                items:
                    schoolProvider.schools
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                onChanged:
                    schoolProvider.isLoading
                        ? null
                        : (value) =>
                            setState(() => _selectedSchoolId = value as int?),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
                readOnly: isReadOnlyMode,
              ),

              const SizedBox(height: 16),

              CustomDropdownField<String?>(
                label: 'Turno Ida',
                hint: 'Período da aula',
                value: effectiveShiftGoing,
                items:
                    shiftOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => _selectedShiftGoing = value),
                validator:
                    (v) =>
                        (v == null && isGuardian) ? 'Campo obrigatório' : null,
                readOnly: isReadOnlyMode,
              ),
              const SizedBox(height: 16),
              CustomDropdownField<String?>(
                label: 'Turno Volta',
                hint: 'Período da aula',
                value: effectiveShiftReturn,
                items:
                    shiftOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => _selectedShiftReturn = value),
                validator:
                    (v) =>
                        (v == null && isGuardian) ? 'Campo obrigatório' : null,
                readOnly: isReadOnlyMode,
              ),

              const SizedBox(height: 16),

              if(isDriver)
              CustomDropdownField<int?>(
                label: 'Turma',
                hint:
                teamProvider.isLoading
                    ? 'Carregando turmas...'
                    : 'Selecione a turma',
                value: effectiveTeamId,
                // Usa o ID da turma validado
                items:
                teamProvider.teams
                    .map(
                      (t) => DropdownMenuItem<int>(
                    value: t.id,
                    child: Text(t.name),
                  ),
                )
                    .toList(),
                onChanged:
                teamProvider.isLoading
                    ? null
                    : (value) => setState(() => _selectedTeamId = value),
                validator: null,
                readOnly: !canEditLogistic || isReadOnlyMode,
              ),

              if (isDriver) ...[
                const SizedBox(height: 32),
                const Text(
                  'Responsáveis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppPalette.primary800),
                ),
                const SizedBox(height: 16),
                GuardianCard(
                  name: widget.student!.guardian!.name,
                  phone: widget.student!.guardian!.phone,

                  onCallPressed: () {
                    LauncherUtils.makePhoneCall(context, widget.student!.guardian!.phone);
                  },
                  onChatPressed: () {
                    LauncherUtils.openWhatsApp(context, widget.student!.guardian!.phone);
                  },
                ),
              ],

              const SizedBox(height: 32),

              if (!isReadOnlyMode)
                ElevatedButton(
                  onPressed: studentProvider.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child:
                      studentProvider.isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            isEditing ? 'Salvar Alterações' : 'Cadastrar Aluno',
                          ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
