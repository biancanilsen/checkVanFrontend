import 'package:flutter/material.dart';

import '../../utils/user_session.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  void _logout(BuildContext context) async {
    await UserSession.signOutUser();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(''),
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 4.0,
      shadowColor: Theme.of(context).shadowColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair',
          onPressed: () => _logout(context),
        ),
      ],
    );
    // return AppBar(
    //   title: const Text(''),
    //   automaticallyImplyLeading: false,
    //   scrolledUnderElevation: 4.0,
    //   shadowColor: Theme.of(context).shadowColor,
    // );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
