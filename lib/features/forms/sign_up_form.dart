import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../enum/snack_bar_type.dart';
import '../../provider/login_provider.dart';
import '../../provider/sign_up_provider.dart';
import '../pages/home/home_page.dart';
import '../widgets/van/custom_snackbar.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cnhController = TextEditingController();

  bool _isDriver = false;
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    _cnhController.dispose();
    super.dispose();
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppPalette.red500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          readOnly: onTap != null,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppPalette.neutral600) : null,
          ),
        ),
      ],
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
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

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final signUpProvider = context.read<SignUpProvider>();
    final signUpSuccess = await signUpProvider.signUp(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      birthDate: _birthDate != null ? DateFormat('yyyy-MM-dd').format(_birthDate!) : '',
      driverLicense: _isDriver ? _cnhController.text : null,
    );

    if (!mounted) return;
    if (!signUpSuccess) {
      CustomSnackBar.show(
        context: context,
        label: signUpProvider.error!,
        type: SnackBarType.error,
      );
      return;
    }

    final loginProvider = context.read<LoginProvider>();
    final loginSuccess = await loginProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    if (!loginSuccess) {
      CustomSnackBar.show(
        context: context,
        label: loginProvider.error!,
        type: SnackBarType.error,
      );
      return;
    }

    CustomSnackBar.show(
      context: context,
      label: 'Conta criada com sucesso',
      type: SnackBarType.success,
    );
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignUpProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Dados do cadastro',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preencha seus dados para criar uma conta',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppPalette.neutral600),
            ),
            const SizedBox(height: 32),

            _buildCustomTextField(
              controller: _nameController,
              label: 'Nome',
              hint: 'Digite seu nome completo',
              isRequired: true,
              validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
            // TODO - Adicionar mascara
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _phoneController,
              label: 'Telefone',
              hint: 'Digite seu telefone',
              isRequired: true,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'exemplo@email.com',
              isRequired: true,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obrigatório';
                if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v)) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _passwordController,
              label: 'Senha',
              hint: 'Crie uma senha',
              isRequired: true,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obrigatório';
                if (v.length < 3) return 'Senha muito curta';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _birthDateController,
              label: 'Data de Nascimento',
              hint: 'dd/mm/aaaa',
              isRequired: true,
              onTap: _pickDate,
              suffixIcon: Icons.calendar_today,
              validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Switch(
                  value: _isDriver,
                  onChanged: (value) => setState(() => _isDriver = value),
                ),
                const SizedBox(width: 8),
                const Text('Sou motorista', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),

            if (_isDriver) ...[
              _buildCustomTextField(
                controller: _cnhController,
                label: 'CNH',
                hint: 'Digite o número da sua CNH',
                isRequired: true,
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800,
                  foregroundColor: AppPalette.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: provider.isLoading ? null : _submitForm,
                child: provider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Cadastrar'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
