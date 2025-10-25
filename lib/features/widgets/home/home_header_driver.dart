import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final bool isLoading;
  final String? userName;

  const HomeHeader({
    super.key,
    required this.isLoading,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                // TODO - Consumir imagem do cadastro do usuárop
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=12',
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bom dia,',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  isLoading
                      ? const Text(
                    '...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  )
                      : Text(
                    userName ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: Colors.grey[800],
              size: 28,
            ),
            onPressed: () {
              // Ação ao clicar no sino
            },
          ),
        ],
      ),
    );
  }
}