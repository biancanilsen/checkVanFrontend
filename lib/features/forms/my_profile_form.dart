import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../model/user_model.dart';
import '../../utils/user_session.dart';

class MyProfileForm extends StatefulWidget {
  const MyProfileForm({super.key});

  @override
  State<MyProfileForm> createState() => _MyProfileFormState();
}

class _MyProfileFormState extends State<MyProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _licenseController = TextEditingController();
  final _birthDateController = TextEditingController();

  late int _userId;
  String? _userRole;
  DateTime? _birthDate;

  bool _isLoading = false;
  bool _isLoaded = false;

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
      setState(() {
        _nameController.text = user.name ?? '';
        _phoneController.text = user.phone ?? '';
        _emailController.text = user.email ?? '';
        _licenseController.text = user.driverLicense ?? '';
        if (_birthDate != null) {
          final y = _birthDate!.year;
          final m = _birthDate!.month.toString().padLeft(2, '0');
          final d = _birthDate!.day.toString().padLeft(2, '0');
          _birthDateController.text = '$y-$m-$d';
        }
        _isLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _licenseController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await UserService.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _senhaController.text,
      license: _licenseController.text,
      birthDate: _birthDate!,
    );

    setState(() => _isLoading = false);

    if (success) {
      await UserSession.saveUser(UserModel(
        id: _userId,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        driverLicense: _licenseController.text,
        role: _userRole!,
        birthDate: _birthDate!,
      ));
      await _loadUserProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado!')),
      );

      await Future.delayed(const Duration(milliseconds: 1000));

      final tabController = DefaultTabController.of(context);
      if (tabController != null) tabController.animateTo(0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_nameController, 'Nome'),
              const SizedBox(height: 16),
              _buildField(
                _phoneController,
                'Telefone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildField(
                _emailController,
                'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              // Senha não obrigatória
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  hintText: '******',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_userRole == 'driver') ...[
                _buildField(_licenseController, 'CNH'),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Atualizar perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _birthDateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Data de Nascimento',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
      onTap: () async {
        final picked = await showDatePicker(
          // TODO: ver como deixar em pt-BR
          context: context,
          initialDate: _birthDate != null ? _birthDate! : DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                dialogTheme: DialogThemeData(backgroundColor: Colors.grey.shade200),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _birthDate = picked;
            final y = picked.year;
            final m = picked.month.toString().padLeft(2, '0');
            final d = picked.day.toString().padLeft(2, '0');
            _birthDateController.text = '$y-$m-$d';
          });
        }
      },
    );
  }

  Widget _buildField(
      TextEditingController controller,
      String label, {
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}
