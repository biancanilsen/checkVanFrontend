import 'package:flutter/material.dart';
import '../../../utils/user_session.dart';

class DriverMenu extends StatelessWidget {
  // 1. Aceite o callback
  final Function(String routeName) onItemTapped;

  const DriverMenu({
    super.key,
    required this.onItemTapped, // 2. Torne-o obrigatório
  });

  void _logout(BuildContext context) async {
    await UserSession.signOutUser();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Botão de Fechar (Topo, Direita) ---
            Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // --- 2. Cabeçalho do Perfil ---
            GestureDetector(
              // 3. Use o callback aqui
              onTap: () => onItemTapped('/my_profile'),
              child: Container(
                padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Meu perfil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 3. Itens do Menu (Meio, com Rolagem) ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 4. Passe o callback para o widget auxiliar
                  _buildMenuItem(context, 'Meus alunos', Icons.arrow_forward_ios, '/students'),
                  _buildMenuItem(context, 'Minhas escolas', Icons.arrow_forward_ios, '/schools'),
                  _buildMenuItem(context, 'Minhas vans', Icons.arrow_forward_ios, '/vans'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.grey[700]),
                title: Text(
                  'Sair',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Modifique o _buildMenuItem para usar o callback
  Widget _buildMenuItem(BuildContext context, String title, IconData trailingIcon, String routeName) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(trailingIcon, size: 18, color: Colors.grey),
          // Use o callback aqui
          onTap: () => onItemTapped(routeName),
        ),
      ],
    );
  }
}