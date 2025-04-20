// import 'package:flutter/material.dart';
//
// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();
//
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/logo_check_van.png',
//                 height: 120,
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Entre na sua conta',
//                 overflow: TextOverflow.fade,
//                 maxLines: 1,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               const SizedBox(height: 24),
//               TextField(
//                 controller: emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(16)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Senha',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(16)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     // backgroundColor: const Color(0xFFFFC532),
//                     backgroundColor: const Color(0xFF101C2C),
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/home');
//                   },
//                   child: const Text('Entrar'),
//                 ),
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/signup');
//                   },
//                   child: const Text('Criar conta'),
//                 )
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/login_provider.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
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
              Text(
                'Entre na sua conta',
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              provider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  final success = await provider.login(
                    emailController.text,
                    passwordController.text,
                  );

                  if (success && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    // ajustar essa mensagem de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.error ?? 'Erro inesperado')),
                    );
                  }
                },
                child: const Text('Entrar'),
              ),
              // SizedBox(
              provider.isLoading
                  ? const SizedBox(height: 16)
                  : SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Criar conta'),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

