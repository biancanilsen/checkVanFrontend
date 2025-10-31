import 'package:check_van_frontend/features/pages/van/add_van_page.dart';
import 'package:flutter/material.dart';
import '../../pages/profile/my_profile.dart';
import '../../pages/school/add_school_page.dart';
import '../../pages/school/school_page.dart';
import '../../pages/student/students_page.dart';
import '../../pages/team/add_team_page.dart';
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
  int _selectedIndex = 0; // Para o BottomNavBar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista de páginas do BottomNavBar
  static const List<Widget> _navBarPages = [
    HomeDriverContent(), // Antiga HomeDriver
    TeamsPage(),       // 'Turmas'
    VanPage(),           // 'Mensagens'
  ];

  // A página atual sendo exibida no Body
  late Widget _currentBody;

  @override
  void initState() {
    super.initState();
    _currentBody = _navBarPages[0]; // Começa com a Home
  }

  // Chamado pelo BottomNavBar
  void _onBottomNavItemTapped(int index) {
    if (index == 3) { // Índice 3 é o botão 'Menu'
      _scaffoldKey.currentState?.openEndDrawer();
      return; // Não muda o índice
    }

    setState(() {
      _selectedIndex = index;
      _currentBody = _navBarPages[index];
    });
  }

  // Chamado pelo Drawer (Menu Lateral)
  void _onDrawerItemTapped(String routeName) {
    Navigator.pop(context); // Fecha o drawer
    Widget newPage;
    int newIndex = -1; // -1 = nenhuma aba do BottomNav selecionada

    // Mapeia as rotas do drawer para os widgets
    switch (routeName) {
      case '/my_profile':
        newPage = const MyProfile();
        break;
      case '/students':
        newPage = const StudentPage();
        break;
      case '/schools':
        newPage = const SchoolPage();
        break;
      case '/vans':
      // Se a VanPage também está no BottomNav, só selecionamos a aba
        _onBottomNavItemTapped(2); // O índice 2 é 'Mensagens' (VanPage)
        return;
      default:
        newPage = _navBarPages[0]; // Padrão
        newIndex = 0;
    }

    setState(() {
      _currentBody = newPage;
      // Se abrimos algo que não está no BottomNav,
      // podemos resetar o índice para 'Rotas' (0) ou -1.
      // Vamos manter 'Rotas' selecionado.
      _selectedIndex = (newIndex == -1) ? 0 : newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // O Drawer agora recebe o callback
      endDrawer: DriverMenu(onItemTapped: _onDrawerItemTapped),
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavItemTapped,
      ),
      // O body agora é dinâmico
      body: _currentBody,
    );
  }
}