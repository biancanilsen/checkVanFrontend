import 'package:flutter/material.dart';
import '../../../model/user_model.dart'; // Import do seu model
import '../../../utils/user_session.dart';

class DriverMenu extends StatelessWidget {
  final Function(String routeName) onItemTapped;

  const DriverMenu({
    super.key,
    required this.onItemTapped,
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
            // --- 1. Botão de Fechar ---
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

            // --- 2. Cabeçalho do Perfil (COM FUTURE BUILDER) ---
            FutureBuilder<UserModel?>(
              future: UserSession.getUser(), // Busca os dados salvos
              builder: (context, snapshot) {
                final user = snapshot.data;
                final imageProfile = user?.imageProfile;
                final userName = user?.name ?? 'Meu perfil';

                return GestureDetector(
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
                        // Lógica da Imagem
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (imageProfile != null && imageProfile.isNotEmpty)
                              ? NetworkImage(imageProfile)
                              : const AssetImage('assets/profile.png') as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // --- 3. Itens do Menu ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(context, 'Meus alunos', Icons.arrow_forward_ios, '/students'),
                  _buildMenuItem(context, 'Minhas escolas', Icons.arrow_forward_ios, '/schools'),
                  _buildMenuItem(context, 'Minhas vans', Icons.arrow_forward_ios, '/vans'),
                ],
              ),
            ),

            // --- 4. Logout ---
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
          onTap: () => onItemTapped(routeName),
        ),
      ],
    );
  }
}