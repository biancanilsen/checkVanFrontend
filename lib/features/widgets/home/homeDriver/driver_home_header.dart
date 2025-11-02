import 'package:flutter/material.dart';

class DriverHomeHeader extends StatelessWidget {
  final bool isLoading;
  final String? userName;
  final String? imageProfile;
  final VoidCallback onProfileTap;

  const DriverHomeHeader({
    super.key,
    required this.isLoading,
    this.userName,
    required this.imageProfile,
    required this.onProfileTap,
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
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: (imageProfile != null && imageProfile!.isNotEmpty)
                      ? NetworkImage(imageProfile!)
                      : const AssetImage('assets/profile.png') as ImageProvider,
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
          // IconButton(
          //   icon: Icon(
          //     Icons.notifications_none_outlined,
          //     color: Colors.grey[800],
          //     size: 28,
          //   ),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/add-school');
          //   },
          // ),
        ],
      ),
    );
  }
}