import 'package:flutter/material.dart';

class StudentTile extends StatelessWidget {
  final String name;
  final String address;
  final VoidCallback onActionPressed;
  final bool isGuardian;

  const StudentTile({
    super.key,
    required this.name,
    required this.address,
    required this.onActionPressed,
    required this.isGuardian,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      leading: const CircleAvatar(
        radius: 35,
        backgroundImage: AssetImage('assets/retratoCrianca.webp'),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        address,
        style: TextStyle(color: Colors.grey[700]),
      ),
      // 3. Ícone e Ação dinâmicos
      trailing: IconButton(
        icon: Icon(
          // Se for guardian, mostra 'editar', senão mostra 'ver'
          isGuardian ? Icons.edit_outlined : Icons.visibility_outlined,
          color: Colors.grey[600],
          size: 20,
        ),
        onPressed: onActionPressed, // A ação é a mesma (abrir a página)
      ),
      // 4. Ação de clique no tile (opcional, mas bom para UX)
      onTap: onActionPressed,
    );
  }
}