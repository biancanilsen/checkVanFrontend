import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../services/user_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/van/custom_snackbar.dart';
import '../../../enum/snack_bar_type.dart';
import '../../../utils/user_session.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Validações
  bool get _has8Chars => _passwordController.text.length >= 8;
  bool get _hasUpper => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLower => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  bool get _isValid => _has8Chars && _hasUpper && _hasLower && _hasNumber && _hasSpecial;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Ícone Cadeado
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF2F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: AppPalette.primary800,
                ),
              ),
              const SizedBox(height: 24),
              const Text("Criar Nova Senha", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.primary800)),
              const SizedBox(height: 8),
              const Text("Sua nova senha deve ser diferente das senhas anteriores", textAlign: TextAlign.center, style: TextStyle(color: AppPalette.neutral700, fontSize: 16)),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _passwordController,
                label: "Nova senha",
                hint: "Digite sua nova senha",
                obscureText: _obscurePassword,
                suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                onSuffixIconTap: () => setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (_) => setState(() {}),
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: "Confirmar senha",
                hint: "Confirme sua nova senha",
                obscureText: _obscureConfirm,
                suffixIcon: _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                onSuffixIconTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                isRequired: true,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sua senha deve conter:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildRequirement("Mínimo de 8 caracteres", _has8Chars),
                    _buildRequirement("Pelo menos uma letra maiúscula", _hasUpper),
                    _buildRequirement("Pelo menos uma letra minúscula", _hasLower),
                    _buildRequirement("Pelo menos um número", _hasNumber),
                    _buildRequirement("Pelo menos um caractere especial (!@#\$%...)", _hasSpecial),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isValid) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Redefinir senha", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppPalette.primary800),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Cancelar", style: TextStyle(color: AppPalette.primary800, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- CORREÇÃO AQUI ---
  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6), // Aumentei um pouco o espaçamento
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha o ícone ao topo caso o texto quebre linha
        children: [
          // Ícone fixo
          Icon(met ? Icons.check_circle : Icons.cancel, color: met ? Colors.green : Colors.grey, size: 16),
          const SizedBox(width: 8),

          // Texto Flexível (Correção do Overflow)
          Expanded(
            child: Text(
                text,
                style: TextStyle(color: met ? Colors.green : Colors.grey[700], fontSize: 13)
            ),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      CustomSnackBar.show(context: context, label: "As senhas não conferem", type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    // Chama o serviço (que deve usar parâmetro opcional 'password')
    final success = await UserService.updateProfile(
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      // Atualiza a sessão local se necessário (removendo flag temporária)
      final user = await UserSession.getUser();
      if (user != null) {
        // O ideal é recarregar o user do backend, mas para UX imediata basta fechar
      }

      if (mounted) {
        Navigator.pop(context);
        CustomSnackBar.show(context: context, label: "Senha redefinida com sucesso!", type: SnackBarType.success);
      }
    } else {
      CustomSnackBar.show(context: context, label: "Erro ao redefinir senha", type: SnackBarType.error);
    }
  }
}