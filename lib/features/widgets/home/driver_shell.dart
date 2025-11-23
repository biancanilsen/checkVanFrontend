import 'package:flutter/material.dart';
import '../../pages/team/teams_page.dart';
import '../../pages/van/van_page.dart';
import '../../widgets/home/homeDriver/driver_main_bottom_nav_bar.dart';
import '../menu/menu.dart';
import 'homeDriver/home_driver_content.dart';
import '../../pages/student/students_page.dart';
import '../../pages/school/school_page.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late PageController _pageController;
  Widget? _overlayPage;

  static const List<Widget> _pages = [
    HomeDriverContent(),
    TeamsPage(),
    VanPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavItemTapped(int index) {
    if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    if (index == _selectedIndex) return;

    setState(() {
      _overlayPage = null;
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 6. ATUALIZE A LÓGICA DO DRAWER
  void _onDrawerItemTapped(String routeName) {
    Navigator.pop(context); // Fecha o drawer

    // Navegue dentro do Shell quando possível para manter o BottomNavBar visível
    switch (routeName) {
      case '/vans':
        // Se for 'vans', apenas mude a aba (já estamos no Shell)
        _onBottomNavItemTapped(2);
        break;
      case '/students':
        // Renderiza StudentsPage como overlay dentro do Shell mantendo o BottomNavBar
        setState(() {
          _overlayPage = const StudentPage();
        });
        break;
      case '/schools':
        // Renderiza SchoolPage como overlay dentro do Shell mantendo o BottomNavBar
        setState(() {
          _overlayPage = const SchoolPage();
        });
        break;
      default:
        // Para demais rotas, navegue normalmente (o BottomNavBar some)
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
      body: WillPopScope(
        onWillPop: () async {
          if (_overlayPage != null) {
            setState(() {
              _overlayPage = null;
            });
            return false;
          }
          return true;
        },
        child: Stack(
          children: [
            PageView(
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
            if (_overlayPage != null) _overlayPage!,
          ],
        ),
      ),
    );
  }
}