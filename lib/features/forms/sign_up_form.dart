import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/login_provider.dart';
import '../../provider/sign_up_provider.dart';
import '../pages/home_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignUpProvider>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  helperText: ' ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),

              // Telefone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  helperText: ' ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  helperText: ' ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 2),

              // Senha
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  helperText: ' ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value.length < 3) return 'Senha muito curta';
                  return null;
                },
              ),

              // Data de Nascimento com DatePicker
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  helperText: ' ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo obrigatório' : null,
                onTap: () async {
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
                      final d = picked.day.toString().padLeft(2, '0');
                      final m = picked.month.toString().padLeft(2, '0');
                      final y = picked.year;
                      _birthDateController.text = '$d/$m/$y';
                    });
                  }
                },
              ),

              // CNH (visível apenas para motorista)
              Row(
                children: [
                  Switch(
                    value: _isDriver,
                    onChanged: (value) => setState(() => _isDriver = value),
                    activeColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.5),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 8),
                  const Text('Sou motorista'),
                ],
              ),

              if (_isDriver) ...[
                TextFormField(
                  controller: _cnhController,
                  decoration: const InputDecoration(
                    labelText: 'CNH',
                    helperText: ' ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
              ],

              const SizedBox(height: 24),

              // Botão Cadastrar / Loading
              provider.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF101C2C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  // 1) tenta cadastrar
                  final signUpSuccess = await context.read<SignUpProvider>().signUp(
                  name: _nameController.text,
                  phone: _phoneController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                    birthDate: _birthDate != null
                        ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                        : '',
                    driverLicense: _isDriver ? _cnhController.text : null,
                  );

                  if (!signUpSuccess) {
                  // mostra erro de cadastro
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(context.read<SignUpProvider>().error!)));
                  return;
                  }

                  // 2) se cadastrou, tenta logar
                  final loginProvider = context.read<LoginProvider>();
                  final loginSuccess = await loginProvider.login(
                  _emailController.text,
                  _passwordController.text,
                  );

                  if (!loginSuccess) {
                  // mostra erro de login (raríssimo, mas pode acontecer)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(loginProvider.error!)));
                  return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conta criada com sucesso')),
                  );
                  // 3) tudo ok, navega pra Home
                  Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                  },
                child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
