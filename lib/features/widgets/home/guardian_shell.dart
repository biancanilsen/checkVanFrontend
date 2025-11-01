import 'package:check_van_frontend/features/pages/home/home_guardian.dart';
import 'package:flutter/material.dart';

import '../../pages/student/students_page.dart';
import '../../widgets/home/homeGuaridan/guardian_bottom_nav_bar.dart';

class GuardianShell extends StatefulWidget {
  const GuardianShell({super.key});

  @override
  State<GuardianShell> createState() => _GuardianShellState();
}

class _GuardianShellState extends State<GuardianShell> {
  int _selectedIndex = 0;

  // 1. Crie um PageController
  late PageController _pageController;

  // 2. A lista de páginas permanece a mesma
  static const List<Widget> _pages = <Widget>[
    HomeGuardian(),
    StudentPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 3. Inicialize o PageController
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    // 4. Lembre-se de descartar o controller
    _pageController.dispose();
    super.dispose();
  }

  // 5. Atualize o método _onItemTapped
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    // 6. Diga ao PageView para animar para a nova página
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300), // Duração da animação
      curve: Curves.easeInOut, // Curva da animação
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      // 7. Substitua o body por um PageView
      body: PageView(
        controller: _pageController,
        children: _pages,
        // 8. (Opcional) Desabilite o "deslizar" com o dedo
        // physics: const NeverScrollableScrollPhysics(),

        // 9. Se o usuário deslizar, atualize o ícone da barra
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      bottomNavigationBar: GuardianBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}