import 'package:flutter/material.dart';

import '../../utils/custom_nav_bar_item.dart';

class GuardianBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const GuardianBottomNavBar({
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
              icon: Icons.check_circle_outline,
              activeIcon: Icons.check_circle,
              label: 'Presença',
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
            CustomNavBarItem(
              icon: Icons.people_outlined,
              activeIcon: Icons.people,
              label: 'Alunos',
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
          ],
        ),
      ),
    );
  }
}