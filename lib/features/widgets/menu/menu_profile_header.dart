import 'package:flutter/material.dart';
import '../../../../model/user_model.dart';
import '../../../../utils/user_session.dart';

class MenuProfileHeader extends StatelessWidget {
  final VoidCallback onTap;

  const MenuProfileHeader({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: UserSession.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final imageProfile = user?.imageProfile;
        final userName = user?.name ?? 'Meu perfil';

        return GestureDetector(
          onTap: onTap,
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
    );
  }
}