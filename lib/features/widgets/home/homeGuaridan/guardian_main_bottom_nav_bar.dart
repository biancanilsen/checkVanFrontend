import 'package:flutter/material.dart';

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
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          activeIcon: Icon(Icons.check_circle),
          label: 'Presença',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Alunos',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed, // Para mostrar ambos os labels
      selectedItemColor: const Color(0xFF0D47A1), // Cor do seu tema
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
    );
  }
}