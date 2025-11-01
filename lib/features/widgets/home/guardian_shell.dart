import 'package:flutter/material.dart';

import '../../pages/home/home_guardian.dart';
import '../../pages/student/students_page.dart';
import '../../widgets/home/homeGuaridan/guardian_bottom_nav_bar.dart';

class GuardianShell extends StatefulWidget {
  const GuardianShell({super.key});

  @override
  State<GuardianShell> createState() => _GuardianShellState();
}

class _GuardianShellState extends State<GuardianShell> {
  int _selectedIndex = 0; // 0 = Presença, 1 = Alunos

  static const List<Widget> _pages = <Widget>[
    HomeGuardian(),
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
      body: _pages.elementAt(_selectedIndex),

      bottomNavigationBar: GuardianBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}