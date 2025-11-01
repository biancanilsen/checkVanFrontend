import 'package:flutter/material.dart';
import '../../utils/custom_nav_bar_item.dart';

class DriverBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const DriverBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = const Color(0xFF0D47A1);
    final Color unselectedColor = Colors.grey[600]!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: SafeArea(
        bottom: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomNavBarItem(
              icon: Icons.route_outlined,
              activeIcon: Icons.route,
              label: 'Rotas',
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
            CustomNavBarItem(
              icon: Icons.people_outlined,
              activeIcon: Icons.people,
              label: 'Turmas',
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
            CustomNavBarItem(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Mensagens',
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
            CustomNavBarItem(
              icon: Icons.menu,
              activeIcon: Icons.menu,
              label: 'Menu',
              isSelected: selectedIndex == 3,
              onTap: () => onItemTapped(3),
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
          ],
        ),
      ),
    );
  }
}