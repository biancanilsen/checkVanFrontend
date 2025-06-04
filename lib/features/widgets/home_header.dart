import 'package:flutter/material.dart';
import '../../utils/user_session.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const HomeHeader({super.key, required this.onLogout});

  Future<String> _loadNameUser() async {
    final user = await UserSession.getUser();
    return user?.name?.isNotEmpty == true ? user!.name : "Usuário";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0F2441),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 48, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/my_profile'),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Olá,', style: TextStyle(color: Colors.white70)),
                FutureBuilder<String>(
                  future: _loadNameUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Carregando...', style: TextStyle(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return const Text('Erro', style: TextStyle(color: Colors.white));
                    } else {
                      return Text(
                        snapshot.data ?? 'Usuário',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
