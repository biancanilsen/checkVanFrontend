import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../core/theme.dart';
import '../../../enum/snack_bar_type.dart';
import '../../../services/user_service.dart';
import '../../../model/user_model.dart';
import '../../../utils/user_session.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/phone_input_country.dart';
import '../../widgets/van/custom_snackbar.dart';
import '../../widgets/user/reset_password/password_requirements_list.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _licenseController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _confirmSenhaController = TextEditingController();

  bool _senhasIguais = true;
  bool _obscureSenha = true;
  bool _obscureConfirmSenha = true;

  late int _userId;
  String? _userRole;
  DateTime? _birthDate;
  String? _profileImageUrl;

  String _selectedDDI = '+55';
  String _selectedCountryCode = 'BR';

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isLoaded = false;
  bool _isDriver = false;

  bool get _isPasswordLengthValid =>
      _senhaController.text.isEmpty || _senhaController.text.length >= 12;

  bool get _canSubmitPassword => _isPasswordLengthValid;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await UserSession.getUser();
    if (user != null) {
      _userId = user.id;
      _userRole = user.role;
      _birthDate = user.birthDate;
      _profileImageUrl = user.imageProfile;

      if (user.phoneCountry != null) {
        _selectedCountryCode = user.phoneCountry!;
      }

      setState(() {
        _isDriver = _userRole == "driver";
        _nameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        _licenseController.text = user.driverLicense ?? '';

        String rawPhone = user.phone ?? '';
        if (rawPhone.startsWith('+')) {
          if (rawPhone.startsWith('+55')) {
            _selectedDDI = '+55';
            _phoneController.text = rawPhone.substring(3);
          } else {
            _phoneController.text = rawPhone;
          }
        } else {
          _phoneController.text = rawPhone;
        }

        if (_birthDate != null) {
          _birthDateController.text = DateFormat('dd/MM/yyyy').format(_birthDate!);
        }
        _isLoaded = true;
      });
    }
  }

  void _validatePasswords() {
    final iguais = _senhaController.text == _confirmSenhaController.text;
    setState(() {
      _senhasIguais = iguais;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmSenhaController.dispose();
    _licenseController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
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
      CustomSnackBar.show(
        context: context,
        label: 'Erro ao selecionar imagem: $e',
        type: SnackBarType.error,
      );
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_senhasIguais) {
      CustomSnackBar.show(context: context, label: 'As senhas não conferem', type: SnackBarType.error);
      return;
    }
    if (!_isPasswordLengthValid) {
      CustomSnackBar.show(context: context, label: 'A senha deve ter no mínimo 12 caracteres', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    String cleanNumber = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    String finalPhone = '$_selectedDDI$cleanNumber';

    bool success = await UserService.updateProfile(
      name: _nameController.text,
      phone: finalPhone,
      phoneCountry: _selectedCountryCode,
      email: _emailController.text,
      password: _senhaController.text,
      license: _licenseController.text,
      birthDate: _birthDate,
    );

    String? newImageUrl;
    if (_imageFile != null) {
      newImageUrl = await UserService.uploadProfileImage(_imageFile!);
    }

    setState(() => _isLoading = false);

    if (success) {
      await UserSession.saveUser(UserModel(
        id: _userId,
        name: _nameController.text,
        phone: finalPhone,
        phoneCountry: _selectedCountryCode,
        email: _emailController.text,
        driverLicense: _licenseController.text,
        role: _userRole!,
        birthDate: _birthDate,
        imageProfile: newImageUrl ?? _profileImageUrl,
      ));

      await _loadUserProfile();

      _senhaController.clear();
      _confirmSenhaController.clear();

      CustomSnackBar.show(
        context: context,
        label: 'Perfil atualizado!',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } else {
      CustomSnackBar.show(
        context: context,
        label: 'Erro ao atualizar perfil',
        type: SnackBarType.error,
      );
    }
  }

  void _logout() async {
    await UserSession.signOutUser();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary800,
      ),
      body: !_isLoaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Meus dados',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _isDriver ? AppPalette.primary800 : AppPalette.primary900),
              ),
              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : (_profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/profile.png')) as ImageProvider,
                    child: _imageFile == null
                        ? Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppPalette.primary900,
                        child: const Icon(Icons.edit, color: Colors.white),
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
                hint: 'Seu nome completo',
                isRequired: true,
                textCapitalization: TextCapitalization.words,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              PhoneInputWithCountry(
                controller: _phoneController,
                label: 'Telefone',
                isRequired: true,
                initialDialCode: _selectedDDI,
                onCountryChanged: (ddi) {
                  _selectedDDI = ddi;
                },
                onCountryIsoChanged: (isoCode) {
                  _selectedCountryCode = isoCode;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'seuemail@email.com',
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _birthDateController,
                label: 'Data de nascimento',
                hint: 'dd/mm/aaaa',
                isRequired: true,
                readOnly: true,
                onTap: _pickDate,
                onSuffixIconTap: _pickDate,
                suffixIcon: Icons.calendar_today,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _senhaController,
                label: 'Nova Senha',
                hint: 'Deixe em branco para não alterar',
                obscureText: _obscureSenha,
                onChanged: (_) => _validatePasswords(),
                suffixIcon: _obscureSenha ? Icons.visibility_off : Icons.visibility,
                onSuffixIconTap: () {
                  setState(() => _obscureSenha = !_obscureSenha);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmSenhaController,
                label: 'Confirmar Nova Senha',
                hint: 'Repita a nova senha',
                obscureText: _obscureConfirmSenha,
                onChanged: (_) => _validatePasswords(),
                validator: (v) => _senhasIguais ? null : 'As senhas não coincidem',
                suffixIcon: _obscureConfirmSenha ? Icons.visibility_off : Icons.visibility,
                onSuffixIconTap: () {
                  setState(() => _obscureConfirmSenha = !_obscureConfirmSenha);
                },
              ),

              if (_senhaController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                PasswordRequirementsList(
                  password: _senhaController.text,
                ),
              ],

              const SizedBox(height: 16),

              if (_userRole == 'driver') ...[
                CustomTextField(
                  controller: _licenseController,
                  label: 'Carteira Nacional de Trânsito (CNH)',
                  hint: 'Número da CNH',
                  isRequired: true,
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: ElevatedButton(
                  onPressed: _isLoading || !_canSubmitPassword ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDriver ? AppPalette.primary800 : AppPalette.green600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Salvar'),
                ),
              ),
              const SizedBox(height: 40),

              if (_userRole == 'guardian')
                Center(
                  child: TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.black),
                    label: const Text(
                      'Sair',
                      style: TextStyle(
                          color: AppPalette.primary900,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
    );
  }
}