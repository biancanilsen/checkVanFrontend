import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/sign_up_provider.dart';
import '../forms/sign_up_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpProvider>(
      create: (_) => SignUpProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cadastro')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo_check_van.png',
                  height: 120,
                ),
                const SizedBox(height: 24),
                const SignUpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}