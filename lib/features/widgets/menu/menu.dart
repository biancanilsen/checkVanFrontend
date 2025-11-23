import 'package:flutter/material.dart';

import 'menu_close_button.dart';
import 'menu_item_tile.dart';
import 'menu_logout_tile.dart';
import 'menu_profile_header.dart';

class DriverMenu extends StatelessWidget {
  final Function(String routeName) onItemTapped;

  const DriverMenu({
    super.key,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MenuCloseButton(),

            MenuProfileHeader(
              onTap: () => onItemTapped('/my_profile'),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  MenuItemTile(
                    title: 'Meus alunos',
                    icon: Icons.arrow_forward_ios,
                    onTap: () => onItemTapped('/students'),
                  ),
                  MenuItemTile(
                    title: 'Minhas escolas',
                    icon: Icons.arrow_forward_ios,
                    onTap: () => onItemTapped('/schools'),
                  ),
                  MenuItemTile(
                    title: 'Minhas vans',
                    icon: Icons.arrow_forward_ios,
                    onTap: () => onItemTapped('/vans'),
                  ),
                ],
              ),
            ),

            const MenuLogoutTile(),
          ],
        ),
      ),
    );
  }
}