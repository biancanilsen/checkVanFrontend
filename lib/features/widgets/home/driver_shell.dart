import 'package:flutter/material.dart';
import '../../pages/team/teams_page.dart';
import '../../pages/van/van_page.dart';
import '../../widgets/home/homeDriver/driver_main_bottom_nav_bar.dart';
import '../menu/menu.dart';
import 'home_driver_content.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 1. Crie um PageController
  late PageController _pageController;

  // 2. Defina as páginas que fazem parte do PageView
  //    (O "Menu" não entra aqui)
  static const List<Widget> _pages = [
    HomeDriverContent(),
    TeamsPage(),
    VanPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 3. Inicialize o PageController
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 4. Atualize a lógica de toque na barra inferior
  void _onBottomNavItemTapped(int index) {
    // Se clicar no "Menu", abra o Drawer
    if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    // Se clicar em um item já selecionado, não faz nada
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    // 5. Anime para a página correspondente
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 6. ATUALIZE A LÓGICA DO DRAWER
  void _onDrawerItemTapped(String routeName) {
    Navigator.pop(context); // Fecha o drawer

    // Itens do Drawer agora NAVEGAM para uma nova tela
    // em vez de trocar o body.
    switch (routeName) {
      case '/vans':
      // Se for 'vans', apenas mude a aba (já estamos no Shell)
        _onBottomNavItemTapped(2);
        break;
      default:
      // Para 'MyProfile', 'Students', 'Schools', etc.,
      // navegue para a tela (o BottomNavBar vai sumir)
        Navigator.pushNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // O Drawer e o BottomNavBar permanecem os mesmos
      endDrawer: DriverMenu(onItemTapped: _onDrawerItemTapped),
      bottomNavigationBar: DriverBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavItemTapped,
      ),
      // 7. SUBSTITUA O BODY POR UM PAGEVIEW
      body: PageView(
        controller: _pageController,
        children: _pages,

        // Atualiza o ícone selecionado se o usuário
        // deslizar a tela com o dedo
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}