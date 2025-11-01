import 'package:flutter/material.dart';

import '../../pages/home/home_guardian_content.dart';
import '../../pages/student/students_page.dart';
import '../../widgets/home/homeGuaridan/guardian_bottom_nav_bar.dart';

class GuardianShell extends StatefulWidget {
  const GuardianShell({super.key});

  @override
  State<GuardianShell> createState() => _GuardianShellState();
}

class _GuardianShellState extends State<GuardianShell> {
  int _selectedIndex = 0; // 0 = Presença, 1 = Alunos

  // Lista de páginas para o body
  static const List<Widget> _pages = <Widget>[
    GuardianHomeContent(),
    StudentPage(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      // O body agora é dinâmico, baseado no índice
      body: _pages.elementAt(_selectedIndex),

      // O BottomNavBar agora mora aqui
      bottomNavigationBar: GuardianBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}