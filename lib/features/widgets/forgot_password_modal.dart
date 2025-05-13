import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/forgot_password_provider.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({Key? key}) : super(key: key);

  @override
  _ForgotPasswordModalState createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgotPasswordProvider>();

    return AlertDialog(
      title: const Text('Email'),
      content: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        // TextButton(
        //   onPressed: () => Navigator.of(context).pop(),
        //   child: const Text('Cancelar'),
        // ),
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
            final success = await provider.sendRecoveryEmail(_emailController.text);
            if (success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Confira a caixa de entrada de seu email para obter o acesso a conta novamente',
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(provider.error ?? 'Erro inesperado')),
              );
            }
          },
          child: provider.isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}