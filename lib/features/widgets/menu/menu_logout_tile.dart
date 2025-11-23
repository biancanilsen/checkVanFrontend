import 'package:flutter/material.dart';
import '../../../../utils/user_session.dart';

class MenuLogoutTile extends StatelessWidget {
  const MenuLogoutTile({super.key});

  void _logout(BuildContext context) async {
    await UserSession.signOutUser();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}