import 'package:flutter/material.dart';

class StudentTile extends StatelessWidget {
  final String name;
  final String address;
  final VoidCallback onEditPressed;

  const StudentTile({
    super.key,
    required this.name,
    required this.address,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      // Avatar
      leading: const CircleAvatar(
        radius: 30,
        // Imagem mocada
        // TODO - recuperar essa imagem do endpoint
        backgroundImage: AssetImage('assets/retratoCrianca.webp'),
      ),
      // Nome
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      // Endereço
      subtitle: Text(
        address,
        style: TextStyle(color: Colors.grey[700]),
      ),
      // Ícone de Editar
      trailing: IconButton(
        icon: Icon(Icons.edit_outlined, color: Colors.grey[600], size: 20),
        onPressed: onEditPressed,
      ),
    );
  }
}