import 'package:flutter/material.dart';
import '../../services/driver_service.dart';

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

  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await DriverService.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _senhaController.text,
      license: _licenseController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      // limpa os campos, avaliar se é legal isso
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _senhaController.clear();
      _licenseController.clear();

      // feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado!')),
      );

      await Future.delayed(const Duration(milliseconds: 1000));

      // navega para a aba de índice 1
      final tabController = DefaultTabController.of(context);
      if (tabController != null) {
        tabController.animateTo(0);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildField(_nameController, 'Nome'),
              const SizedBox(height: 16),
              _buildField(_phoneController, 'Telefone', keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField(_senhaController, 'Senha', obscureText: true),
              const SizedBox(height: 16),
              _buildField(_licenseController, 'CNH'),
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

  Widget _buildField(TextEditingController controller, String label,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
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
