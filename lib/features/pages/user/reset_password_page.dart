import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../services/user_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user/reset_password/password_requirements_list.dart';
import '../../widgets/user/reset_password/reset_password_header.dart';
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

  // (NIST SP 800-63B)
  bool get _isValid => _passwordController.text.length >= 12;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      CustomSnackBar.show(context: context, label: "As senhas não conferem", type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    final success = await UserService.updateProfile(
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      await UserSession.getUser(); // Atualiza sessão se necessário
      if (mounted) {
        Navigator.pop(context);
        CustomSnackBar.show(context: context, label: "Senha redefinida com sucesso!", type: SnackBarType.success);
      }
    } else {
      if (mounted) {
        CustomSnackBar.show(context: context, label: "Erro ao redefinir senha", type: SnackBarType.error);
      }
    }
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              const ResetPasswordHeader(),

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

              // Passa apenas a senha atual para o widget calcular a força
              PasswordRequirementsList(
                password: _passwordController.text,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isValid) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}